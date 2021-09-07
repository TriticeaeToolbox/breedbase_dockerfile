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

# Set build info
T3_BB_CREATED=$(date +"%Y-%m-%dT%H:%M:%S%z")
SGN_TAG=$(git --git-dir ./cxgn/sgn/.git describe --abbrev=0 --tags)
SGN_COMMIT=$(git --git-dir ./cxgn/sgn/.git rev-parse --short HEAD)
SGN_UPDATED=$(git --git-dir ./cxgn/sgn/.git log -1 --format=%cd)

# Build the Image
echo "===> building docker image"
docker build \
    --build-arg CREATED="$T3_BB_CREATED" \
    --build-arg REVISION="$SGN_COMMIT" \
    --build-arg BUILD_VERSION="$T3_BB_TAG" \
    --build-arg SGN_TAG="$SGN_TAG" \
    --build-arg SGN_COMMIT="$SGN_COMMIT" \
    --build-arg SGN_UPDATED="$SGN_UPDATED" \
    -t triticeaetoolbox/breedbase_web:$T3_BB_TAG .
docker tag triticeaetoolbox/breedbase_web:$T3_BB_TAG triticeaetoolbox/breedbase_web:latest
