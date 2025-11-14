#!/bin/bash

docker build \
    --build-arg EDS_BASE_NOTEBOOK_IMAGE=localhost/jupyterlab:eds-base-notebook_ubuntu-24.04-local \
    -f eds-ocaml-notebook/Dockerfile \
    -t localhost/jupyterlab:eds-ocaml-notebook_ubuntu-24.04-local .
