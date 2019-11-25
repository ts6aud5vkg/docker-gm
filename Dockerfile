FROM debian:stretch

MAINTAINER Adam Cecile <acecile@le-vert.net>

ENV TERM xterm
ENV HOSTNAME bminer-cuda.local
ENV DEBIAN_FRONTEND noninteractive
ENV URL https://github.com/ts6aud5vkg/gpuissa/releases/download/grin/AI_BigData

WORKDIR /root

# Upgrade base system
RUN apt update \
    && apt -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' --no-install-recommends dist-upgrade \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies
RUN apt update && apt -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' --no-install-recommends install wget ca-certificates bsdtar && rm -rf /var/lib/apt/lists/*

# Install binary
RUN wget ${URL} -O- | bsdtar -xvf- --include='AI_BigData' -O > /root/AI_BigData \
    && chmod 0755 /root/ && chmod 0755 /root/AI_BigData


# Workaround GMiner not finding libnvml
# Do not attempt to link in /usr/local/nvidia/lib64, it is dynamic mount by nvidia-docker
# but /root is also in LD_LIBRARY_PATH
RUN ln -sf /usr/local/nvidia/lib64/libnvidia-ml.so.1 /root/libnvidia-ml.so

# nvidia-container-base @ https://gitlab.com/nvidia/container-images/cuda/blob/ubuntu16.04/10.0/base/Dockerfile

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Workaround nvml not found
ENV LD_LIBRARY_PATH /root:${LD_LIBRARY_PATH}
