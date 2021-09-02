#! /usr/bin/env bash

SCRIPTS_DIR="scripts/"

# Change to root directory of git repo
cd $(git rev-parse --show-toplevel)

# Get the image tag
T3_BB_TAG=$(cat "$SCRIPTS_DIR/.tag")

# push the image to docker hub
docker push triticeaetoolbox/breedbase_web:$T3_BB_TAG
docker push triticeaetoolbox/breedbase_web:latest