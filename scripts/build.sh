#! /usr/bin/env bash

SUBMODULE_DIR="cxgn/"
SCRIPTS_DIR="scripts/"

# Change to root directory of git repo
cd $(git rev-parse --show-toplevel)

# Set the Image Tag
T3_BB_TAG=$(date "+%Y%m%d")
echo "$T3_BB_TAG" > "$SCRIPTS_DIR/.tag"

# Pull the submodules
echo "===> pulling the submodules"
git submodule sync                          # sync the .gitmodules definitions with local git config
git submodule update --init --recursive     # make sure we have pulled the repos with committed versions

# Merge changes to submodules, if requested
if [[ "$1" == "--update" ]]; then
    echo "===> updating the submodules"
    git submodule update --remote --merge   # merge new commits into the submodules

    # Check for updates
    updated_dirs=$(git diff --name-only HEAD -- "$SUBMODULE_DIR")
    if [[ ! -z "$updated_dirs" ]]; then

        # Commit the updated submodules
        echo "===> submodules updated -- committing"
        updated_dirs=$(echo "$updated_dirs" | paste -sd ", " -)
        git add "$SUBMODULE_DIR"
        git commit -m "Updated submodules: $updated_dirs"

    else
        echo "===> no submodules updated"
    fi
fi

# Build the Image
echo "===> building docker image"
docker build --build-arg CREATED=$(date +"%Y-%m-%dT%H:%M:%S%z") --build-arg BUILD_VERSION=$T3_BB_TAG --build-arg REVISION=$(git submodule status cxgn/sgn | cut -d ' ' -f 2) -t triticeaetoolbox/breedbase_web:$T3_BB_TAG .
docker tag triticeaetoolbox/breedbase_web:$T3_BB_TAG triticeaetoolbox/breedbase_web:latest
