"""
This module provides helper functions for Google Pub/Sub.
"""

import base64
import json


def decode(data):
    """
    Decodes data coming from Pub/Sub.

    Args:
        data (str): The data you want to decode.

    Returns:
        dict: The decoded message.
    """
    return json.loads(base64.b64decode(data).decode("utf-8"))


def _encode(data):
    return json.dumps(data).encode("ascii")


def to_topic(messages, topic=None):
    """
    Publishes messages to a Pub/Sub topic.

    Args:
        messages (list[dict]): The messages.
        topic (str, optional): The topic. If not provided, defaults to
            `os.environ["GCF_UTILS_PUBSUB_TOPIC"]`.
    """
    from google.cloud import pubsub_v1

    publisher = pubsub_v1.PublisherClient()
    topic = topic or os.environ["GCF_UTILS_PUBSUB_TOPIC"]

    futures = [publisher.publish(topic, _encode(data)) for data in messages]
    _ = [future.result() for future in futures]
