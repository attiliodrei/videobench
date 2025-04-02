FROM ubuntu:20.04

ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get  install -y --no-install-recommends software-properties-common 
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get  install -y --no-install-recommends  python3.10 python3.10-venv python3.10-dev
# get and install building tools
RUN \
        apt-get update && \
        apt-get install -y --no-install-recommends \
        build-essential \
        git \
        ninja-build \
        nasm \
        doxygen \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        python3-tk \
        yasm \
        pkg-config \
        && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists


# install python requirements
        RUN pip3 install --upgrade pip
        RUN pip3 install --no-cache-dir meson cython numpy

# setup environment
        ENV PATH=/vmaf:/vmaf/libvmaf/build/tools:$PATH


RUN \
        mkdir /tmp/vmaf \
        && cd /tmp/vmaf \
        && git clone https://github.com/Netflix/vmaf.git . \
        && make \
        && make install \
        && cp -r ./model /usr/local/share/ \
        && rm -r /tmp/vmaf


RUN \
        mkdir /tmp/ffmpeg \
        && cd /tmp/ffmpeg \
        && git clone https://git.ffmpeg.org/ffmpeg.git . \
        && ./configure --enable-libvmaf --enable-version3 --pkg-config-flags="--static" \
        && make -j 8 install \
        && rm -r /tmp/ffmpeg



RUN \
        mkdir -p /home/shared-vmaf

RUN \
        ldconfig
