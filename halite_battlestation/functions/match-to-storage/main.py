"""
Reads a match from a Pub/Sub message and uploads it to Google Cloud Storage.
"""

import gzip
import json

from cloud_functions_utils import decode, to_bucket, error_reporting


BUCKET = "kaggle-halite"


def _transform(data):
    return gzip.compress(json.dumps(data).encode("ascii"))


@error_reporting
# pylint: disable=unused-argument
def main(event, context):
    # pylint: enable=unused-argument
    """
    Reads a match from a Pub/Sub message and uploads it to Google Cloud Storage.
    """
    env = decode(event["data"])["env"]
    filepath = f"matches/{env['id']}.json.gzip"
    to_bucket(_transform(env), filepath, BUCKET)
