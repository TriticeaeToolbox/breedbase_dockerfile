#! /usr/bin/env bash

# Change to root directory of git repo
cd $(git rev-parse --show-toplevel)

#
# Set the SGN repo, branch, and commit to use
# SGN_REPO = user/repo of the sgn repository to build (default: TriticeaeToolbox/sgn)
# SGN_BRANCH = name of the sgn repo branch to build (default: t3/master)
#
# All of these can be overriden with environment variables, if desired
# 
SGN_REPO="${SGN_REPO:-TriticeaeToolbox/sgn}"
SGN_BRANCH="${SGN_BRANCH:-t3/master}"
SGN_COMMIT=$(curl --silent https://api.github.com/repos/$SGN_REPO/branches/$SGN_BRANCH | jq -r '.commit.sha')

#
# Set the Docker image and tag to use
# DOCKER_IMAGE = user and image to use as the image name (default: triticeaetoolbox/breedbase_web)
# DOCKER_TAG = the tag to use for the new image (default: YYYYMMDD)
# DOCKER_CHANNEL = the release channel for the new image (default: latest)
#
# All of these can be overriden with environment variables, if desired
#
DOCKER_IMAGE="${DOCKER_IMAGE:-triticeaetoolbox/breedbase_web}"
DOCKER_TAG="${DOCKER_TAG:-$(date "+%Y%m%d")}"
DOCKER_CHANNEL="${DOCKER_CHANNEL:-latest}"
DOCKER_CREATED=$(date +"%Y-%m-%dT%H:%M:%S%z")


echo "===> BUILDING DOCKER IMAGE..."
echo "SGN REPO: $SGN_REPO"
echo "SGN BRANCH: $SGN_BRANCH"
echo "SGN COMMIT: $SGN_COMMIT"
echo "DOCKER IMAGE: $DOCKER_IMAGE"
echo "DOCKER TAG: $DOCKER_TAG"
echo "DOCKER CHANNEL: $DOCKER_CHANNEL"
echo "DOCKER CREATED: $DOCKER_CREATED"


# Build the Image
DOCKER_BUILDKIT=1 docker build \
    --build-arg DOCKER_TAG="$DOCKER_TAG" \
    --build-arg DOCKER_CREATED="$DOCKER_CREATED" \
    --build-arg SGN_REPO="$SGN_REPO" \
    --build-arg SGN_BRANCH="$SGN_BRANCH" \
    --build-arg SGN_COMMIT="$SGN_COMMIT" \
    -t $DOCKER_IMAGE:$DOCKER_TAG .
docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:$DOCKER_CHANNEL

# Deploy the Image, if requested with --deploy
if [[ "$1" == "--deploy" ]]; then
    DOCKER_IMAGE="$DOCKER_IMAGE" DOCKER_TAG="$DOCKER_TAG" DOCKER_CHANNEL="$DOCKER_CHANNEL" bash ./scripts/deploy.sh
fi