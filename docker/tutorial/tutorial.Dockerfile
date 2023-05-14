FROM nvidia/cuda:11.7.1-devel-ubuntu20.04
ENV DEBIAN_FRONTEND noninteractive

# ================= Dependencies ===================
# python
RUN apt-get update -y
ENV http_proxy $HTTPS_PROXY
ENV https_proxy $HTTPS_PROXY

RUN apt-get update && apt-get install ffmpeg libsm6 libxext6 wget unzip openexr libopenexr-dev -y

RUN apt-get install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa && apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    python3.10-venv \
    python3.10-distutils \
    python3.10-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
RUN curl https://bootstrap.pypa.io/get-pip.py | sudo python3

# kilonerf dependencies
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN python3 -m pip install pip --upgrade

# ================= User & Environment Setup, Repos ===================
ENV DEBIAN_FRONTEND interactive
ENV PATH="/usr/local/cuda-11.7/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.7/lib64:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH"

COPY docker/fixuid_setup.sh /project/fixuid_setup.sh
RUN /project/fixuid_setup.sh
USER docker:docker
WORKDIR /home/docker/

ENV DEBIAN_FRONTEND interactive

ENTRYPOINT ["/usr/local/bin/fixuid"]
CMD ["sleep", "inf"]
