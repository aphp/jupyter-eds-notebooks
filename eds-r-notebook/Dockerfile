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


# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]


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
        fonts-dejavu \
        unixodbc \
        unixodbc-dev \
        r-cran-rodbc \
        gfortran \
        less \
        && \ 
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# macOS Rosetta virtualization creates junk directory which gets owned by root further up.
# It'll get re-created, but as USER runner after the next directive so hopefully should not cause permission issues.
#
# More info: https://github.com/jupyter/docker-stacks/issues/2296
RUN rm -rf "/home/${NB_USER}/.cache/"

# Copying config files for base environment update & custom conda configuration
COPY --chown=${NB_USER}:${NB_GID} "./eds-r-notebook/config/conda-r-env-update.yaml" "${CONDA_DIR}/conda-r-env-update.yaml"

# Installing environment dependencies according to the YAML env file copied earlier
RUN mamba update --all && \
    mamba env update \
        --name base \
        --file "${CONDA_DIR}"/conda-r-env-update.yaml && \
    mamba clean --all -f -y

# Trivy scan fix: 
# Removing the fake service account json file that is used for testing gargle package in R, as it is not needed in the final image and can cause confusion for users who might think it is a real service account key file.
RUN rm -rf "${CONDA_DIR}"/lib/R/library/gargle/extdata/fake_service_account.json

# Setting permissions and freezing base env
RUN fix-permissions "/home/${NB_USER}" && \
    chown -R root:root "${CONDA_DIR}" && \
    chmod -R 755 "${CONDA_DIR}"

# Switching to NB_USER that will be the runtime notebook user  
USER ${NB_USER}
