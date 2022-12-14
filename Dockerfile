FROM jupyter/all-spark-notebook:x86_64-latest

ARG NB_UID=1000
ARG NB_GID=1000

USER root

# Graphviz
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends graphviz curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# GCC (needed for XGBoost)
RUN mamba install --quiet --yes gcc && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}" && 
    curl -LO https://github.com/abiosoft/colima/releases/download/v0.4.0/colima-$(uname)-$(uname -m) && 
    install colima-$(uname)-$(uname -m) /usr/local/bin

COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/

COPY --chown=${NB_UID}:${NB_GID} demo/demo.ipynb demo.ipynb

RUN pip install --quiet --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
    
COPY --chown=${NB_UID}:${NB_GID} datascience-ultimate/overrides.json /opt/conda/share/jupyter/lab/settings/overrides.json    
