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

# +
from google.cloud import pubsub_v1

# pylint: enable=import-outside-toplevel

publisher = pubsub_v1.PublisherClient()
# -

publisher.publish()

from cloud_functions_utils import to_topic
from kaggle_environments import make

# +
AGENTS = [
    "eu.gcr.io/kaggle-halite/janjagusch/halite-agent:lazy",
    "eu.gcr.io/kaggle-halite/janjagusch/halite-agent:random",
    "eu.gcr.io/kaggle-halite/janjagusch/halite-agent:random",
    "eu.gcr.io/kaggle-halite/janjagusch/halite-agent:random",
]

CONFIGURATION = make("halite").configuration

SEED = 42

TAGS = []
# -

messages = [
    {"agents": AGENTS, "configuration": CONFIGURATION, "seed": i, "tags": TAGS}
    for i in range(100)
]

to_topic(messages, "projects/kaggle-halite/topics/match-request", b64encode=False)
