#! /usr/bin/env bash


#
# Set the Docker image and tag to use
# DOCKER_IMAGE = user and image to use as the image name (default: triticeaetoolbox/breedbase_web)
# DOCKER_TAG = the tag of the image to push, first argument or DOCKER_TAG env var
# DOCKER_CHANNEL = the release channel of the image to push, second argument or DOCKER_CHANNEL env var
#
DOCKER_IMAGE="${DOCKER_IMAGE:-triticeaetoolbox/breedbase_web}"
DOCKER_TAG="${DOCKER_TAG:-$1}"
DOCKER_CHANNEL="${DOCKER_CHANNEL:-$2}"

if [[ -z "$DOCKER_TAG" ]]; then
	echo "ERROR: You must provide the tag to push!"
	exit 1
fi

echo "===> DEPLOYING DOCKER IMAGE..."
echo "DOCKER IMAGE: $DOCKER_IMAGE"
echo "DOCKER TAG: $DOCKER_TAG"
if [[ ! -z "$DOCKER_CHANNEL" ]]; then
	echo "DOCKER CHANNEL: $DOCKER_CHANNEL"
fi

# push the tagged image to docker hub
echo "---> pushing $DOCKER_IMAGE:$DOCKER_TAG"
docker push $DOCKER_IMAGE:$DOCKER_TAG

# push the channel image, if provided
if [[ ! -z "$DOCKER_CHANNEL" ]]; then
	echo "---> pushing $DOCKER_IMAGE:$DOCKER_CHANNEL"
	docker push $DOCKER_IMAGE:$DOCKER_CHANNEL
fi
