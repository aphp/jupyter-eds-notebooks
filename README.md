[![ci-eds-notebooks](https://github.com/aphp/jupyter-eds-notebooks/actions/workflows/ci-eds-notebooks.yaml/badge.svg)](https://github.com/aphp/jupyter-eds-notebooks/actions/workflows/ci-eds-notebooks.yaml)

# jupyter-eds-notebooks

`jupyter-eds-notebooks` is a collection of Docker images extending the official Jupyter Docker Stacks, tailored for health and clinical research. It provides opinionated Jupyter environments for data science and experimentation on EDS-like (health data warehouse) infrastructures.

These images are one of the building blocks of **[HELIX – Health and Exploration Lab for Innovative eXperiments](https://github.com/aphp/HELIX)**, a broader initiative to provide a reproducible, secure, and user‑friendly environment for health research.

Repository: https://github.com/aphp/jupyter-eds-notebooks

---

## Goals

The main goals of this project are to:

- Offer **ready‑to‑use Jupyter environments** for health data science (Python, statistics, visualization, notebooks).
- Ensure **consistency** across researchers and projects by standardizing base images and dependencies.
- Facilitate **integration with HELIX** and datalab platforms (authentication, data access patterns, recommended libraries).
- Provide a **reproducible, versioned, and documented** way to build and maintain these environments.

---

## Relationship to HELIX

**HELIX** (*Health and Exploration Lab for Innovative eXperiments*) is a wider project aiming to:

- Provide a **secure, production‑grade environment** for health data exploration and experimentation.
- Integrate data access, governance, observability, and developer tooling for research teams.
- Support **reproducible computational experiments** and collaboration across teams.

Within this ecosystem, `jupyter-eds-notebooks` specifically focuses on:

- The **Jupyter runtime images** used by HELIX (for example in JupyterHub, batch jobs, or interactive lab workspaces).
- Capturing **HELIX‑specific conventions** (preferred Python stack, system packages, kernels, tooling, etc.).
- Offering a base that can be **extended by individual teams** when needed.

---

## Included tools and features

The core images include tools and settings that support the features exposed to end‑users.

### Development tools

- `git`
- `vim`
- `curl`
- `gohdfs` (HDFS CLI client)
- `mamba` (fast drop‑in replacement for `conda`)

### Data‑science tools

- **Voilà** – turn notebooks into dashboards and web apps.
- **Quarto** – scientific and technical publishing from notebooks and documents.
- **ipywidgets** – interactive widgets for Jupyter notebooks and dashboards.

### Quality‑of‑Life (QoL) enhancements

- **`jupyter-resource-usage` extension** to monitor JupyterLab RAM and CPU usage.
- **Curated JupyterLab settings presets** to make the main features easier to discover and use.
- **Dynamic Bash prompt with Starship**, providing a rich, informative shell prompt.
- **Jupyter Language Server Protocol (LSP)**:
  - Code completion and inline documentation in notebooks.
  - IDE‑like features in the JupyterLab code editor.

### Hardening and restrictions

- **Disabled, non‑wanted extensions and behaviours:**
  - File downloads directly from JupyterLab.
  - Non‑authenticated notebook sharing from JupyterLab.

- **Extension manager blocked**:
  - Disabled in the JupyterLab UI.
  - Disabled at the command‑line level, to keep environments reproducible and controlled.

### JupyterLab pre‑configuration

Out‑of‑the‑box, the images ship with opinionated defaults, including:

- **Jupyter LSP enabled and configured** for common languages.
- **Hidden files not shown by default** in the JupyterLab file browser.
- **JupyterLab update pop‑up disabled**, to avoid confusing prompts in managed environments.

### Conda environment protection

- The default `conda` environment (`base`) is mounted **read‑only**.  
  This prevents users from accidentally breaking the shared environment while still allowing them to work with additional environments or user‑level tools where appropriate.

---

## Images overview

This repository is organized as a set of build contexts, each producing a specialized Jupyter image. Typical examples include:

- `eds-base-notebook`: a base EDS / HELIX data science environment (Python, scientific stack, notebook tooling).
- `eds-<something>-notebook`: images adding specific languages, frameworks, or tools for particular workflows.
- `local/`: helper scripts and local tooling to build and run these images in a consistent way.

Each image directory contains:

- a `Dockerfile` describing the image,
- any additional configuration files or scripts needed at build or runtime.

Please refer to each subdirectory for the exact configuration and list of included packages.

---

## Architecture and relationship to Jupyter Docker Stacks

The images in this repository are built **on top of the official Jupyter Docker Stacks** (such as `base-notebook`), adding HELIX‑specific tooling, security hardening, and UX improvements.

You can refer to the following diagram for more details :


![Relationship between jupyter-eds-notebooks and Jupyter Docker Stacks](resources/jupyter-eds-notebook.drawio.svg)

---

## Quick start

### Prerequisites

- A recent Docker installation.
- Access to any internal registry (if you plan to push and share images).
- Optional: a JupyterHub / HELIX deployment where you want to plug these images.

---

## Build images using helper scripts

Instead of calling `docker build` manually, this repository provides **helper scripts under the `local/` directory** to build the different notebook images in a consistent way.

Typical workflow:

1. Go to the `local/` directory:

        cd local

2. Use the provided build scripts to build one or several images, for example:

        ./build-eds-base-notebook.sh
        ./build-all.sh

3. Follow the script output for available options (tags, registry, etc.).

The exact script names and options are documented inside the `local/` directory (and/or its own README). They are the recommended entry point for building images.

---

## Run images using helper scripts

Similarly, the `local/` directory provides **run scripts** to start containers locally with sensible defaults (ports, volumes, environment variables, etc.), so you do not need to craft long `docker run` commands by hand.

From the root of the repository or from `local/`:

        cd local
        ./run-eds-base-notebook.sh

Then open the URL printed by the script (usually a Jupyter URL with a token) in your browser.

Please refer to the documentation and comments in the `local/` scripts for the exact image names, ports, and configuration.

---

## Using the images with JupyterHub / HELIX

In a JupyterHub or HELIX deployment, you can typically reference these images as the **single-user image**. For example, in a Helm values file you might configure:

        singleuser:
          image:
            name: aphp/jupyter-eds-base-notebook
            tag: "x86_64-ubuntu-24.04"        # or "x86_64-ubuntu-24.04-dev" / "nightly"
          # Additional configuration (resources, env vars, volumes, etc.) goes here

How these images are integrated (and which image is the default) is defined in the HELIX or JupyterHub platform configuration.

---

## Tags and release channels

Images follow a **fixed set of tags**, corresponding to different stability levels:

- `x86_64-ubuntu-24.04`  
  → **Stable** image, recommended for production and standard use.

- `x86_64-ubuntu-24.04-dev`  
  → **Development** image, including more recent or experimental changes. Suitable for testing upcoming updates.

- `nightly`  
  → **Nightly** build, automatically rebuilt from the latest state of the repository. Intended for testing and early feedback only.

**Recommended usage:**

- For production JupyterHub / HELIX deployments, **pin to** `x86_64-ubuntu-24.04`.
- For pre‑production or integration testing, use `x86_64-ubuntu-24.04-dev`.
- For trying the very latest changes (at your own risk), use `nightly`.

Downstream configurations should always pin an explicit tag (not `latest`) to ensure **reproducibility**.

---

## Repository layout

A typical layout of the repository looks like:

        .
        ├── eds-base-notebook/      # Base EDS / HELIX Jupyter environment (Dockerfile, build context)
        ├── eds-*/                  # Additional specialized notebook images
        ├── local/                  # Helper scripts to build and run images locally
        ├── resources/              # Documentation assets (e.g. architecture diagrams in SVG/drawio format)
        ├── .github/workflows/      # CI configuration for building and validating images
        ├── CONTRIBUTING.md         # Contribution guidelines
        ├── MAINTAINERS.md          # Maintainer information
        ├── NOTICE                  # Notices and attributions
        ├── SECURITY.md             # Security policy
        ├── LICENSE                 # License file
        └── README.md               # This document

(Names and exact content may vary; see the live repository for details.)

---

## Contributing

Contributions are welcome. Typical ways to contribute include:

- Adding or updating dependencies in existing images.
- Proposing new specialized images (for specific languages, frameworks, or use cases).
- Improving documentation and examples.
- Reporting bugs or security issues.

Before opening a pull request, please:

- Check existing issues and pull requests.
- Follow any coding and Dockerfile style guidelines described in `CONTRIBUTING.md`.
- Add or update documentation when changing image content or behavior.

For security issues, please follow the process described in `SECURITY.md`.

---

## License

See the `LICENSE` file in the repository for the full license text and terms.

---

## Acknowledgements

- The **Jupyter Docker Stacks** project, for the base notebook images and best practices around containerized Jupyter environments.
- The teams behind **HELIX** and health data warehouses (EDS and similar platforms), for providing requirements, feedback, and ongoing maintenance efforts.
