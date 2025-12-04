# Base OCaml EDS Notebook

[![ci-eds-notebooks](https://github.com/aphp/jupyter-eds-notebooks/actions/workflows/ci-eds-notebooks.yaml/badge.svg)](https://github.com/aphp/jupyter-eds-notebooks/actions/workflows/ci-eds-notebooks.yaml)

## Introduction

### Description

Extension of the JupyterLab [`base-notebook`](https://github.com/jupyter/docker-stacks/tree/main/images/base-notebook) image providing a minimal working environment, enriched with the tooling required for OCaml workflows.

### How it works

This image is built on top of the official `base-notebook` image, and extends it in the same spirit as the other official Jupyter Docker Stacks images, in order to stay highly compatible with standard JupyterLab distributions.

The image is based on the `Ubuntu 24.04` operating system, targeting the `x86_64` architecture.

Additional libraries to be installed are configured in a file that is copied at build time. The resulting default environment is then **frozen** so that users cannot accidentally break it.

To achieve this, the following measures are applied:

- File permissions on the default `conda` environment directory (`base`) are set to **read‑only**.
- The environment variable `PYTHONNOUSERSITE` is set to `1` to prevent the use of the user‑local Python repository in `/home/jovyan/.local`, which would otherwise allow users to bypass the read‑only restriction on the default `conda` environment.

## Usage

### Configuration

The `config` directory contains two files:

- `.condarc`: the default configuration for the `conda` distribution shipped in the image.
- `conda-base-env-update.yaml`: the list of libraries to be installed into the default `conda` environment at build/runtime.

#### Changing the conda configuration

Edit `config/.condarc` according to the [official conda configuration documentation](https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html), then rebuild the image.

#### Adding or removing libraries in the default conda environment

Edit `config/conda-base-env-update.yaml` to [add or remove the desired packages](https://conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-file-manually), then rebuild the image.

**Important:**  
Do **not** add top‑level keys such as `name`, `channels`, or any other root‑level keys to `config/conda-base-env-update.yaml`. Doing so would create a **new** `conda` environment instead of enriching the existing default one that already contains all dependencies required by JupyterLab. This would make the image non‑functional.
