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

# # Publishing messages to Google Pub/Sub

from copy import copy
import json
import random

from kaggle_environments import make

from google.cloud.pubsub_v1 import PublisherClient

SEED = 42
AGENTS = ["random", "random", "random", "random"]
TAGS = [{"key": "type", "value": "DEBUG"}]

random.seed(SEED)

random.seed(SEED)
env = make("halite")
_ = env.reset(num_agents=len(AGENTS))
_ = env.run(copy(AGENTS))

payload = {
    "env": env.toJSON(),
    "agents": AGENTS,
    "seed": SEED,
    "tags": TAGS,
}

publisher = PublisherClient()
topic_name = 'projects/kaggle-halite/topics/match'
result = publisher.publish(topic_name, json.dumps(payload).encode("ascii"))

result.result()
