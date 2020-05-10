# Playing Matches

## Setup

### Prerequisites

* [Docker](https://docs.docker.com/get-docker/)
* [Google Cloud SDK](https://cloud.google.com/sdk/install)
* You have followed all steps in the [Getting Started](../README.md##Getting-Started) section in the [README](../README.md)

### Installation

* Log into your Google account with the Google Cloud SDK ([link](https://cloud.google.com/sdk/docs/authorizing)):

    ```sh
    gcloud auth login
    gcloud auth application-default login # sometimes necessary
    gcloud config set project kaggle-halite
    ```

* Authenticate against the Google Cloud Container Registry ([link](https://cloud.google.com/container-registry/docs/advanced-authentication)). I recommend using gcloud as a credential helper ([link](https://cloud.google.com/container-registry/docs/advanced-authentication#gcloud-helper)):

    ```sh
    gcloud auth configure-docker
    ```

## Running the Script

Optionally: Set then environment variable `MAX_MESSAGES` to define the maximum number of outstanding messages for the worker. If not set, defaults to 1. More information [here](https://cloud.google.com/pubsub/docs/pull#config).

* Start the `match_player.py` script:

    ```sh
    python halite_battlestation/match_player.py # maybe prefix with `poetry run`
    ```

You should now automatically pull messages from Google Cloud PubSub, play matches and publish the result to PubSub.

👾👾 **Congrats!** 👾👾
