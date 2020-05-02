"""
Reads a message from the leaderboard topic and inserts it into Google BigQuery.
"""

from cloud_functions_utils import decode, to_table, error_reporting

PROJECT = "kaggle-halite"
DATASET = "leaderboard"
TABLE = "leaderboard"


@error_reporting
# pylint: disable=unused-argument
def main(event, context):
    # pylint: enable=unused-argument
    """
    Reads a message from the leaderboard topic and inserts it into Google BigQuery.
    """
    data = decode(event["data"])
    to_table([data], PROJECT, DATASET, TABLE)
