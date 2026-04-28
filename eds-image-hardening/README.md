# Base EDS Notebook

## Introduction

### Description

Extension of the JupyterLab [`base-notebook`](https://github.com/jupyter/docker-stacks/tree/main/images/base-notebook) image providing a minimal, opinionated working environment.

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

#### Components included in the notebook image 

|Component|Usage|
|-|-|
|dos2unix| Change files format dos to unix (remove ^m) - [issue 11](https://github.com/aphp/jupyter-eds-notebooks/issues/11) |
|git| [ free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency. ](https://git-scm.com/) |
|vim|  [Vi text editor](https://www.vim.org/) |
|tree|   Tree is a recursive directory listing program that produces a depth indented listing of files, which  is  colorized  ala  dircolors  if  the LS_COLORS  environment variable is set and output is to tty. |
|curl| curl  is  a  tool for transferring data from or to a server using URLs. It supports these protocols: DICT, FILE, FTP, FTPS, GOPHER, GOPHERS, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, MQTT, POP3, POP3S, RTMP, RTMPS, RTSP, SCP, SFTP, SMB, SMBS, SMTP, SMTPS, TELNET, TFTP, WS and WSS. |
