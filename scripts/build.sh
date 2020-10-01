#! /bin/bash

# get script and docker directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPTS_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
DOCKER_DIR="$(dirname $SCRIPTS_DIR)"

# use the yyyymmdd timestamp as the tag
T3_BB_TAG=$(date "+%Y%m%d")
echo "$T3_BB_TAG" > "$SCRIPTS_DIR/.tag"

# update the repos
"$SCRIPTS_DIR/prepare.sh"

# build the image
docker build -t triticeaetoolbox/breedbase_web:$T3_BB_TAG "$DOCKER_DIR"
docker tag triticeaetoolbox/breedbase_web:$T3_BB_TAG triticeaetoolbox/breedbase_web:latest
