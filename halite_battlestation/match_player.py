"""
Pull subscriber to Google PubSub subscription that plays matches.
"""

from contextlib import contextmanager
from copy import copy
import os
import random
import socket
import warnings


from cloud_functions_utils import decode, error_reporting, to_topic
from google.cloud import pubsub_v1
from google.cloud.pubsub_v1.gapic.publisher_client_config import config
from kaggle_environments import make
import docker
import requests


SUBSCRIPTION_NAME = "projects/kaggle-halite/subscriptions/match-play"
TOPIC_NAME = "projects/kaggle-halite/topics/match"
TIMEOUT = None
MAX_MESSAGES = int(os.environ.get("MAX_MESSAGES", 1))


def _publisher_config():
    # https://github.com/googleapis/python-pubsub/issues/7#issuecomment-603092768
    # also to account for my tv cable upload speed :shit:
    config["interfaces"]["google.pubsub.v1.Publisher"]["retry_params"]["messaging"][
        "initial_rpc_timeout_millis"
    ] = 60_000
    config["interfaces"]["google.pubsub.v1.Publisher"]["retry_params"]["messaging"][
        "rpc_timeout_multiplier"
    ] = 1.0
    config["interfaces"]["google.pubsub.v1.Publisher"]["retry_params"]["messaging"][
        "max_rpc_timeout_millis"
    ] = 60_000


class _Code:
    def __init__(self, co_argcount):
        self.co_argcount = co_argcount


class _RequestAgent:
    def __init__(self, url):
        self._url = url
        self.__code__ = _Code(2)

    def __call__(self, observation, configuration):
        data = {"observation": observation, "configuration": configuration}
        return requests.post(url=self._url, json=data).json()


def _free_tcp_port():
    # https://gist.github.com/gabrielfalcao/20e567e188f588b65ba2
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as tcp:
        tcp.bind(("", 0))
        _, port = tcp.getsockname()
        tcp.close()
        return port


def _host_port(container):
    # https://github.com/docker/docker-py/issues/1742#issuecomment-329799670
    return container.attrs["HostConfig"]["PortBindings"]["80/tcp"][0]["HostPort"]


def _make_env(num_agents, configuration, seed):
    random.seed(seed)
    env = make("halite", configuration)
    _ = env.reset(num_agents=num_agents)
    return env


@contextmanager
def _launch_containers(agents):
    docker_client = docker.from_env()
    containers = [
        docker_client.containers.run(agent, detach=True, ports={80: _free_tcp_port()})
        for agent in agents
    ]
    try:
        yield containers
    finally:
        for container in containers:
            container.stop()
            container.remove()


def _play_match(agents, env):
    with _launch_containers(agents) as containers:
        acts = [
            _RequestAgent(f"http://localhost:{_host_port(container)}/act")
            for container in containers
        ]
        _ = env.run(copy(acts))
        return env


def _make_payload(env, agents, seed, tags):
    return {
        "env": env.toJSON(),
        "agents": agents,
        "seed": seed,
        "tags": tags,
    }


def _main(agents, configuration, seed, tags=None):
    tags = tags or []
    env = _make_env(len(agents), configuration, seed)
    print("Playing match...")
    _play_match(agents, env)
    payload = _make_payload(env, agents, seed, tags)
    print(f"Publishing match '{env.id}'...")
    future = to_topic([payload], topic=TOPIC_NAME, b64encode=False)[0]
    future.result()


def subscribe():
    """
    Subscribes to a Google PubSub subscription, plays a match and publishes the match
    to a PubSub topic.
    """

    subscriber = pubsub_v1.SubscriberClient()

    @error_reporting
    def callback(message):
        print("Message received.")
        data = decode(message.data, b64decode=False)
        _main(**data)
        message.ack()
        print("Done.")

    flow_control = pubsub_v1.types.FlowControl(max_messages=MAX_MESSAGES)

    streaming_pull_future = subscriber.subscribe(
        SUBSCRIPTION_NAME, callback=callback, flow_control=flow_control
    )
    print(f"Listening for messages on {SUBSCRIPTION_NAME}...")

    with subscriber:
        try:
            streaming_pull_future.result(timeout=TIMEOUT)
        except Exception as error:
            streaming_pull_future.cancel()
            raise error


if __name__ == "__main__":
    warnings.filterwarnings(
        "ignore", "Your application has authenticated using end user credentials"
    )
    subscribe()
