#!/bin/bash
docker build \
    --build-arg EDS_BASE_NOTEBOOK_IMAGE=localhost/jupyterlab:eds-base-notebook_ubuntu-24.04-local \
    -f eds-r-notebook/Dockerfile \
    -t localhost/jupyterlab:eds-r-notebook_ubuntu-24.04-local .
