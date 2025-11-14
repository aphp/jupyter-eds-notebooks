# Defining global build argument
ARG JUPYTER_BASE_NOTEBOOK_IMAGE

# Latest image (depending on the environment) from Jupyter Quay.io repository
FROM ${JUPYTER_BASE_NOTEBOOK_IMAGE}

# Declaring build arguments
ARG GIT_PROJECT
ARG GIT_BRANCH
ARG GIT_COMMIT_AUTHOR
ARG GIT_COMMIT_SHA
ARG NOTEBOOK_IMAGE
ARG NOTEBOOK_MAINTAINER

# Defining labels
LABEL MAINTAINER="I&D/SAT/AAM"
LABEL GIT_PROJECT=${GIT_PROJECT}
LABEL GIT_BRANCH=${GIT_BRANCH}
LABEL GIT_COMMIT_AUTHOR=${GIT_COMMIT_AUTHOR}
LABEL GIT_COMMIT_SHA=${GIT_COMMIT_SHA}

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

# Installing extra requirements
RUN apt update --yes && \
    apt upgrade --yes && \
    apt install --yes --no-install-recommends \
        bash-completion \
        fonts-firacode \
        openssh-client \
        make \
        gcc \
        g++ \
        npm \
        binutils \
        libgl1 \
        libglx-mesa0 \
        git \
        vim \
        curl \
        tree &&\
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Installing language-servers Lab extensions as global packages, fto prevent the node_module folder from being erased at runtime
# Pining down version of unified-language-server (notably used for markdown) as per https://github.com/jupyter-lsp/jupyterlab-lsp/issues/1040#issuecomment-2416042706
RUN npm install --global --save-dev \
        bash-language-server \
        dockerfile-language-server-nodejs \
        pyright \
        sql-language-server \
        typescript-language-server \
        unified-language-server@0.3.0 \
        vscode-css-languageserver-bin \
        vscode-html-languageserver-bin \
        vscode-json-languageserver-bin \
        yaml-language-server && \
    npm cache clean --force

# Installing gohdfs binary
ARG GOHDFS_VERSION="2.4.0"
RUN curl -s -L "https://github.com/colinmarc/hdfs/releases/download/v${GOHDFS_VERSION}/gohdfs-v${GOHDFS_VERSION}-linux-amd64.tar.gz" | tar -xzvf - -C /tmp && \
    cp /tmp/gohdfs-v${GOHDFS_VERSION}-linux-amd64/hdfs /usr/local/bin/hdfs &&\
    cp /tmp/gohdfs-v${GOHDFS_VERSION}-linux-amd64/bash_completion /usr/share/bash-completion/completions/hdfs &&\
    rm -rf /tmp/gohdfs-v${GOHDFS_VERSION}linux-amd64

# Switching to NB_USER for local tools/libs installation
USER ${NB_USER}

# Copying config files for base environment update & custom conda configuration
COPY --chown=${NB_USER}:${NB_GID} "./eds-base-notebook/config/conda-base-env-update.yaml" "${CONDA_DIR}/conda-base-env-update.yaml"
COPY --chown=${NB_USER}:${NB_GID} "./eds-base-notebook/config/.condarc" "${CONDA_DIR}/.condarc"

# Installing environment dependencies according to the YAML env file copied earlier
RUN mamba update --all && \
    mamba env update \
        --name base \
        --file "${CONDA_DIR}"/conda-base-env-update.yaml && \
    mamba clean --all -f -y

# Disabling unwanted extensions & locking the extension manager
RUN jupyter labextension disable \
        @jupyterlab/extensionmanager-extension \
        @jupyterlab/docmanager-extension:download \
        @jupyterlab/filebrowser-extension:download \
        @jupyter/collaboration-extension:shared-link && \
    jupyter labextension lock

# Switching to root user to set all permissions after packages installations
USER root

# Setting permissions and freezing base env
RUN fix-permissions "/home/${NB_USER}" && \
    chown -R root:root ${CONDA_DIR} && \
    chmod -R 755 ${CONDA_DIR}


# Switching to NB_USER that will be the runtime notebook user  
USER ${NB_USER}

# Setting correct user name for the environment
ENV USER=${NB_USER}
# Enabling the hidden symlink file to be used by the ContentManager, for Jupyter LSP
# Ref. step 6. of Jupyter LSP installation doc -> https://github.com/krassowski/jupyterlab-lsp/blob/main/README.md#installation
ENV NOTEBOOK_ARGS="--ContentsManager.allow_hidden=True"
# Disabling local python user site (no pip install outside of dedicated conda envs)
ENV PYTHONNOUSERSITE=1
# Setting MAMBA_ROOT_PREFIX to avoir warnings
ENV MAMBA_ROOT_PREFIX="${CONDA_DIR}"


# Copying jupyter config templates
COPY --chown=${NB_USER}:${NB_GID} ./eds-base-notebook/config/templates/ /opt/jupyter/templates
# Copying eds-notebook init script
COPY --chown=${NB_USER}:${NB_GID} ./eds-base-notebook/scripts/init-eds-notebook.sh /usr/local/bin/before-notebook.d/init-eds-notebook.sh