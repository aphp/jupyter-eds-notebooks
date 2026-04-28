#!/bin/bash
docker build \
    --build-arg BASE_IMAGE=quay.io/jupyter/r-notebook:x86_64-ubuntu-24.04 \
    -f eds-image-hardening/Dockerfile \
    -t localhost/jupyterlab:eds-r-notebook_ubuntu-24.04-local .
