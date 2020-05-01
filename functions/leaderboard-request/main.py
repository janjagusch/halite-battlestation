"""
Requests the leaderboard for a competition from Kaggle and publishes it into a
Pub/Sub topic.
"""
from csv import DictReader
from datetime import datetime
from io import StringIO
from itertools import islice
from tempfile import TemporaryDirectory
from zipfile import ZipFile

from kaggle import KaggleApi
from cloud_functions_utils import chunks, decode, error_reporting, to_topic, error_reporting


PROJECT = "kaggle-halite"
TOPIC = "leaderboard"
TOPIC_NAME = f"projects/{PROJECT}/topics/{TOPIC}"


def _authenticated_client():
    client = KaggleApi()
    client.authenticate()
    return client


def _extract_leaderboard(competition):
    print(f"Extracting {competition} leaderboard from Kaggle...")
    client = _authenticated_client()
    with TemporaryDirectory() as tmp_dir:
        client.competition_leaderboard_download(competition, tmp_dir)
        with ZipFile(f"{tmp_dir}/{competition}.zip", mode="r") as zip_ref:
            return zip_ref.read(f"{competition}-publicleaderboard.csv").decode(
                "utf-8-sig"
            )


def _transform_record(rank, record, competition, requested_at):
    return {
        "team_id": record["TeamId"],
        "team_name": record["TeamName"],
        "submitted_at": record["SubmissionDate"],
        "score": record["Score"],
        "rank": rank + 1,
        "competition": competition,
        "requested_at": requested_at,
    }


def _transform_leaderboard(leaderboard_str, competition, requested_at):
    print("Transforming leaderboard records...")
    with StringIO(leaderboard_str) as file_pointer:
        reader = DictReader(file_pointer)
        for rank, record in enumerate(
            reversed(sorted(reader, key=lambda record: float(record["Score"])))
        ):
            yield _transform_record(rank, record, competition, requested_at)


@error_reporting
# pylint: disable=unused-argument
def main(event, context):
    # pylint: enable=unused-argument
    """
    Requests the leaderboard for a competition from Kaggle and publishes it into a
    Pub/Sub topic.
    """
    data = decode(event["data"])
    competition = data["competition"]
    top = data.get("top")

    requested_at = datetime.now().isoformat()
    leaderboard = _extract_leaderboard(competition)
    leaderboard = _transform_leaderboard(leaderboard, competition, requested_at)
    if top:
        # pylint: disable=redefined-variable-type
        leaderboard = islice(leaderboard, top)
        # pylint: enable=redefined-variable-type
    leaderboard = list(leaderboard)

    print(f"Publishing {len(leaderboard)} messages to {TOPIC}...")
    for chunk in chunks(leaderboard, chunksize=100):
        to_topic(chunk, TOPIC_NAME)
