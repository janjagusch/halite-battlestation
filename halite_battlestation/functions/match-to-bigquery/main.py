"""
Reads a match from a PubSub message, transforms it and inserts it into BigQuery.
"""

from cloud_functions_utils import (
    camel_to_snake,
    chunks,
    decode,
    error_reporting,
    to_table,
)


PROJECT = "kaggle-halite"
DATASET = "benchmark"


def _actions_table(env):

    match_id = env["id"]

    def yield_actions(env):
        for step, players in enumerate(env["steps"]):
            for player in players:
                for unit_id, action in (player["action"] or {}).items():
                    yield {"step": step, "unit_id": unit_id, "action": action}

    def transform(**kwargs):
        return {
            "match_id": match_id,
            **kwargs,
        }

    return [transform(**kwargs) for kwargs in yield_actions(env)]


def _board_table(env):

    match_id = env["id"]

    def yield_cells(env):
        for step, players in enumerate(env["steps"]):
            observation = players[0]["observation"]
            yield {
                "step": step,
                "halite": list(map(int, observation["halite"])),
            }

    def transform(**kwargs):
        return {"match_id": match_id, **kwargs}

    return [transform(**kwargs) for kwargs in yield_cells(env)]


def _players_table(env):

    match_id = env["id"]

    def yield_players(env):
        for step, players in enumerate(env["steps"]):
            observation = players[0]["observation"]
            for player_index, player in enumerate(players):
                reward = player["reward"]
                halite = observation["players"][player_index][0]
                yield {
                    "step": step,
                    "player_index": player_index,
                    "halite": halite,
                    "reward": reward,
                }

    def transform(**kwargs):
        return {
            "match_id": match_id,
            **kwargs,
        }

    return [transform(**kwargs) for kwargs in yield_players(env)]


def _units_table(env):

    match_id = env["id"]

    def yield_units(env):
        for step, players in enumerate(env["steps"]):
            observation = players[0]["observation"]
            for player_index, (_, shipyards, ships) in enumerate(
                observation["players"]
            ):
                for unit_id, pos in shipyards.items():
                    yield {
                        "step": step,
                        "player_index": player_index,
                        "unit_id": unit_id,
                        "unit_type": "shipyard",
                        "pos": pos,
                        "halite": None,
                    }
                for unit_id, (pos, halite) in ships.items():
                    yield {
                        "step": step,
                        "player_index": player_index,
                        "unit_id": unit_id,
                        "unit_type": "ship",
                        "pos": pos,
                        "halite": halite,
                    }

    def transform(**kwargs):
        return {
            "match_id": match_id,
            **kwargs,
        }

    return [transform(**kwargs) for kwargs in yield_units(env)]


def _matches_table(env, version, agents, seed, tags=None):

    return {
        "match_id": env["id"],
        "name": env["name"],
        "version": version,
        "agents": agents,
        "configuration": {
            camel_to_snake(key): value for key, value in env["configuration"].items()
        },
        "seed": seed,
        "tags": tags or [],
    }


@error_reporting
# pylint: disable=unused-argument
def main(event, context):
    # pylint: enable=unused-argument
    """
    Reads a match from a PubSub message, transforms it and inserts it into BigQuery.
    """
    data = decode(event["data"])
    env = data["env"]

    print("Transforming tables...")
    match = _matches_table(**data)
    actions = _actions_table(env)
    boards = _board_table(env)
    players = _players_table(env)
    units = _units_table(env)

    print("Inserting rows to BigQuery...")
    to_table([match], PROJECT, DATASET, "matches")
    _ = [to_table(chunk, PROJECT, DATASET, "actions") for chunk in chunks(actions)]
    _ = [
        to_table(chunk, PROJECT, DATASET, "boards")
        for chunk in chunks(boards, chunksize=10)
    ]
    _ = [to_table(chunk, PROJECT, DATASET, "players") for chunk in chunks(players)]
    _ = [to_table(chunk, PROJECT, DATASET, "units") for chunk in chunks(units)]
