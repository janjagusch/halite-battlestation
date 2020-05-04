# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.2.4
#   kernelspec:
#     display_name: Python (halite-battlestation)
#     language: python
#     name: halite-battlestation
# ---

from copy import copy
import socket
import random

from kaggle_environments import make
import docker
import requests

# +
AGENTS = [
    "eu.gcr.io/kaggle-halite/janjagusch/halite-agent:lazy",
    "eu.gcr.io/kaggle-halite/janjagusch/halite-agent:random",
    "eu.gcr.io/kaggle-halite/janjagusch/halite-agent:random",
    "eu.gcr.io/kaggle-halite/janjagusch/halite-agent:random",
]

SEED = 42

TAGS = []
# -

random.seed(SEED)

random.seed(SEED)
env = make("halite")
_ = env.reset(num_agents=len(AGENTS))


# +
class Code:
    
    def __init__(self, co_argcount):
        self.co_argcount = co_argcount
        
class act:
    
    def __init__(self, url):
        self._url = url
        self.__code__ = Code(2)
        
    def __call__(self, observation, configuration):
        data = {"observation": observation, "configuration": configuration}
        return requests.post(url=self._url, json=data).json()


# -

client = docker.from_env()


# +
def free_tcp_port():
    # https://gist.github.com/gabrielfalcao/20e567e188f588b65ba2
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as tcp:
        tcp.bind(('', 0))
        addr, port = tcp.getsockname()
        tcp.close()
        return port
    
def host_port(container):
    # https://github.com/docker/docker-py/issues/1742#issuecomment-329799670
    return container.attrs["HostConfig"]["PortBindings"]["80/tcp"][0]["HostPort"]

containers = [client.containers.run(agent, detach=True, ports={80: free_tcp_port()}) for i, agent in enumerate(AGENTS)]
# -

acts = [act(f"http://localhost:{host_port(container)}/act") for container in containers]

_ = env.run(copy(acts))

env.render(mode="ipython")
