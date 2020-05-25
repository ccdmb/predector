FROM continuumio/miniconda3:4.8.2

ENV ENVIRONMENT=predector
ENV VERSION=0.0.1

LABEL maintainer="darcy.ab.jones@gmail.com"
LABEL description="Docker image containing all non-proprietary requirements for the predector pipeline"
LABEL pipeline.name="${ENVIRONMENT}"
LABEL pipeline.version="${VERSION}"

RUN apt-get update && apt-get install -y procps && apt-get clean -y

ENV PATH="/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

COPY environment.yml /
RUN conda env create --force -f /environment.yml \
 && conda clean -a --yes \
 && sed -i '/conda activate base/d' ~/.bashrc

ENV CONDA_PREFIX="/opt/conda/envs/${ENVIRONMENT}"
ENV PATH="${CONDA_PREFIX}/bin:${PATH}"
ENV CPATH="${CONDA_PREFIX}/include:${CPATH}"
ENV LIBRARY_PATH="${CONDA_PREFIX}/lib:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="${CONDA_PREFIX}/lib:${LD_LIBRARY_PATH}"
ENV PYTHONPATH="${CONDA_PREFIX}/lib/python3.7/site-packages:${PYTHONPATH}"

# Needed for theano/deeploc
ENV CC="${CONDA_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-cc"
ENV CXX="${CONDA_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-c++"

CMD [ "${CONDA_PREFIX}/bin/bash" ]
