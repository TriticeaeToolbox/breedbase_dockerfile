# T3/Breedbase Docker Image

<p float="left">
  <img src="T3.png" width="40%">
  <img src="Breedbase.png" width="40%">
</p>

This repo contains the Dockerfile for building the T3 version of [breedbase](https://breedbase.org).  This repository is a fork of the the [original Breedbase Dockerfile](https://github.com/solgenomics/breedbase_dockerfile).  T3 will periodically update this image and it is available for download on Docker Hub as [triticeaetoolbox/breedbase_web](https://hub.docker.com/r/triticeaetoolbox/breedbase_web).

**If you are looking run a prebuilt T3/Breedbase image**, follow the instructions in the [TriticeaeToolbox/breedbase](https://github.com/TriticeaeToolbox/breedbase) repository.  This repo includes instructions on how to set up your Docker host along with helper scripts to setup the intial Breedbase instance(s) and update them when a new image is released.

The main differences between this T3 version of Breedbase and the original Breedbase image include:

- the use of the [T3 sgn repo](https://github.com/TriticeaeToolbox/sgn) (main codebase for breedbase)
    - the T3 version includes some T3-specific changes and features
- pre-loaded trait ontologies for wheat, oat, and barley
- can be used in conjunction with the [TriticeaeToolbox/breedbase](https://github.com/TriticeaeToolbox/breedbase) repository for the Docker host setup and helper scripts

## Build Instructions

To build the image using Docker, use the `./scripts/build.sh` script:

```sh
./scripts/build.sh --update
```

This script will:

- initialize the submodules
- if the `--update` flag is provided:
  - pull in the most recent commits to all of the submodules
  - if this flag is not provided, the submodules will be locked to the commits that were used the last time this repo was updated
- build the T3/Breedbase Docker image
- tag the newly built image with the `latest` and `YYYYMMDD` tags
