FROM jupyter/all-spark-notebook:x86_64-latest

USER root

# Graphviz
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends graphviz && \
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
