# A docker file to build a binary factory for libtorch on Ubuntu 22.04.
#
# Author: Christian Kauten (ckauten@sensoryinc.com)
#
# Copyright (c) 2021 Sensory, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXTERNRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

FROM ubuntu:22.04
LABEL MAINTAINER "Christian Kauten ckauten@sensoryinc.com"
ENV TZ=US/Mountain
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get --fix-missing update
RUN apt-get -y upgrade
RUN apt-get install -y htop nano vim git screen tmux bash
RUN apt-get install -y build-essential clang autoconf libtool pkg-config curl wget zip cmake ninja-build ccache
RUN apt-get install -y libopenblas-dev
RUN apt-get install -y python3 python3-pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 100
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 100
# Cleanup after installing to remove bloat from the image.
RUN apt -y autoremove
RUN apt -y clean

# Copy the PyTorch repository. Because it is a sub-module, we need the host
# git repo as well, otherwise we wont be able to switch branches.
COPY ./build.sh /libtorch-factory/build.sh

# Set the working directory to the head of the repository.
WORKDIR /libtorch-factory
