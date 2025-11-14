#!/bin/bash

docker build \
    --build-arg JUPYTER_BASE_NOTEBOOK_IMAGE=quay.io/jupyter/base-notebook:ubuntu-24.04 \
    -f eds-base-notebook/Dockerfile \
    -t localhost/jupyterlab:eds-base-notebook_ubuntu-24.04-local .
