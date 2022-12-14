FROM jupyter/all-spark-notebook:x86_64-latest

ARG NB_UID=1000
ARG NB_GID=1000

USER root

# Graphviz
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends graphviz curl qemu-utils podman slirp4netns fuse-overlayfs uidmap && \
    curl -LO "https://github.com/lima-vm/lima/releases/download/v0.14.1/lima-0.14.1-Linux-x86_64.tar.gz" && \
    cat lima-0.14.1-Linux-x86_64.tar.gz | tar Cxzvm /usr/local && rm -f lima-0.14.1-Linux-x86_64.tar.gz && \
    curl -LO https://github.com/abiosoft/colima/releases/download/v0.4.0/colima-Linux-x86_64  && \
    install colima-Linux-x86_64 /usr/local/bin/colima && rm -f colima-Linux-x86_64 \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# GCC (needed for XGBoost)
RUN mamba install --quiet --yes gcc && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/

COPY --chown=${NB_UID}:${NB_GID} demo/demo.ipynb demo.ipynb

RUN pip install --quiet --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
    
COPY --chown=${NB_UID}:${NB_GID} datascience-ultimate/overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json    
