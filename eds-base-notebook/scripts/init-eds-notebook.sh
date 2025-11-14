#!/bin/bash

# Script : init-eds-notebook.sh
# Version: 2.0
# Authors : 
#    - Kévin ZGRZENDEK for APHP - I&D
#    - Quentin GOUHOURY for APHP - I&D
# Description : This script initializes the notebook environment by copying template
#               files in the user's environment

#---------------------------------------------------------------------------------------------------------------------------------------------------------

#########################
# FUNCTIONS DECLARATION #
#########################

# Copying the content of the source template directory to the user's destination directory.
# $1 (str): Path to the source template directory
# $2 (str) : Path to the destination directory 
function secure_copy_templates {

    echo "[INFO] Found configuration templates(s) to copy in the following directory : $1."
    cp -rvf "$1/." "$2"
    echo "[INFO] Copy successful."
}

# Adds symlinks to read-only system files or directory that are needed for the user environment to work properly.
# $1 (str) : User home directory
function populate_symlinks {

    echo "[INFO] Populating symlinks..."

    # Allowing Jupyter LSP to read on system-wide libraries to provide hints on those (needed as our 'base' conda env isn't in Jovyan user home directory).
    # Ref. step 5. of Jupyter LSP installation doc -> https://github.com/krassowski/jupyterlab-lsp/blob/main/README.md#installation
    ln -nfs "${CONDA_DIR}" "$1/.lsp_base_symlink"

    # Allowing Jupyter LSP to read on user libraries to provide hints on those 
    ln -nfs "/home/${NB_USER}/envs" "$1/.lsp_user_symlink"

    # Add symlink into home dir to .condarc file into conda dir
    ln -nfs "${CONDA_DIR}/.condarc" "$1/.condarc"

    echo "[INFO] Symlinks populated."
}

# Sources the user's home directory bashrc script, to update its environment.
# $1 (str) : User home directory
function init_user_env {

    echo "[INFO] Sourcing user environment."

    # shellcheck disable=SC1091
    # shellcheck disable=SC1090
    . "$1/.bashrc"

    echo "[INFO] Sourcing succeeded."
}

###########################
# BEGINNING OF THE SCRIPT #
###########################


echo "[INFO] Starting EDS Notebook initialization process."

CONFIG_TEMPLATES_DIR="/opt/jupyter/templates"
USER_HOME_DIR="/home/${NB_USER}"

SOURCE_DIR_SIZE=$(du -ck "$CONFIG_TEMPLATES_DIR" | tail -n 1 | awk '{print $1}')
DEST_DIR_SPACE_LEFT=$(df -P "$USER_HOME_DIR" | awk 'END{print $4}')

# Verifying that we have enough space on the destination directory to copy the configuration templates
if [ "$SOURCE_DIR_SIZE" -gt "$DEST_DIR_SPACE_LEFT" ]; then
    echo "[CRITICAL] : Could not update configuration files in $DEST_HOME_DIR directory."
    echo "Please free at least ${DEST_DIR_SPACE_LEFT}k to proceed with the configuration update."

    exit 0 # Exiting but not blocking the lab deployment
fi

secure_copy_templates "$CONFIG_TEMPLATES_DIR" "$USER_HOME_DIR"
populate_symlinks "$USER_HOME_DIR"
init_user_env "$USER_HOME_DIR"

echo "[INFO] Initialization succeeded."
