ARG EDS_BASE_NOTEBOOK_IMAGE="ghcr.io/aphp/base-eds-notebook:x86_64-ubuntu-24.04"

FROM ${EDS_BASE_NOTEBOOK_IMAGE}

# Declaring build arguments
ARG GIT_PROJECT
ARG GIT_BRANCH
ARG GIT_COMMIT_AUTHOR
ARG GIT_COMMIT_SHA
ARG NOTEBOOK_IMAGE
ARG NOTEBOOK_MAINTAINER

# Defining labels
LABEL maintainer="I&D/SAT/AAM"
LABEL git-project=${GIT_PROJECT}
LABEL git-branch=${GIT_BRANCH}
LABEL git-commit-author=${GIT_COMMIT_AUTHOR}
LABEL git-commit-sha=${GIT_COMMIT_SHA}

ENV DEFAULT_SWITCH_DIR="/opt/opam/switches/default"
ENV KERNEL_DIR="/opt/conda/share/jupyter/kernels/ocaml-jupyter-default"
ENV OPAMSOLVERTIMEOUT="3600"


# Switching to root user for global packages installations
USER root

# Persisting Image informations in env
ENV NOTEBOOK_IMAGE=${NOTEBOOK_IMAGE}
ENV NOTEBOOK_MAINTAINER=${NOTEBOOK_MAINTAINER}
ENV NOTEBOOK_GIT_PROJECT=${GIT_PROJECT}
ENV NOTEBOOK_GIT_BRANCH=${GIT_BRANCH}
ENV NOTEBOOK_GIT_COMMIT_SHA=${GIT_COMMIT_SHA}

# Installing OPAM + OCAML requirements
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
        make \
        gcc \
        opam \
        pkg-config \
        zlib1g-dev \
        libffi-dev \
        libgmp-dev \
        libzmq5-dev \
        rsync && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Creating the base ocaml switch and kernel dirs, and setting suitable ownership
RUN mkdir -p "${DEFAULT_SWITCH_DIR}" && \
    chown -Rv "${NB_USER}:${NB_GROUP}" "${DEFAULT_SWITCH_DIR}"


# Switching to NB_USER for local tools/libs installation
USER ${NB_USER}

# Copying the package definition file with the lib for the "base" switch
COPY ./eds-ocaml-notebook/config/default.opam.locked /tmp/default.opam.locked

# Updating OPAM repositories & installing the "base" switch from the definition file
RUN  opam init --yes \ 
        --bare \
        --auto-setup \
        --shell bash && \
    opam switch create --empty "${DEFAULT_SWITCH_DIR}" && \
    eval "$(opam env --switch=/opt/opam/switches/default --set-switch)" && \
    opam update \
        --all \
        --repositories \
        --upgrade \
        --yes && \
    opam install /tmp/default.opam.locked \
        --deps-only \
        --yes

# Generating the Jupyter Kernel genspec file that will be used by Jupyter to install the OCAML Kernel
RUN eval "$(opam env --switch=/opt/opam/switches/default --set-switch)" && \
    opam exec -- ocaml-jupyter-opam-genspec && \
    grep topfind "/home/${NB_USER}/.ocamlinit" || echo '#use "topfind";;' >> "/home/${NB_USER}/.ocamlinit" && \
    grep Topfind.log "/home/${NB_USER}/.ocamlinit" || echo 'Topfind.log:=ignore;;' >> "/home/${NB_USER}/.ocamlinit"


#Switching back to root to install OPAM Kernel system-wide
USER root 

# Installing the OCAML Kernel from the genspec file generated earlier
RUN eval "$(opam env --switch=/opt/opam/switches/default --set-switch)" && \
    jupyter kernelspec install \
        --sys-prefix \
        --name "ocaml-jupyter-default" \
        "$(opam var share)/jupyter"

# Fixing permissions pn the local user's home resulting to the system-wide kernel install
RUN fix-permissions "/home/${NB_USER}"


# Switching to NB_USER that will be the runtime notebook user  
USER ${NB_USER}
