#!/bin/bash

docker build \
    --build-arg BASE_IMAGE=quay.io/jupyter/base-notebook:ubuntu-24.04 \
    -f eds-image-hardening/Dockerfile \
    -t localhost/jupyterlab:eds-base-notebook_ubuntu-24.04-local .
