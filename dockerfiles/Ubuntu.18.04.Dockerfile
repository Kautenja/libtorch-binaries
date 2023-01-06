# A docker file to build a binary factory for libtorch on Ubuntu 18.04.
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

FROM ubuntu:18.04
LABEL MAINTAINER "Christian Kauten ckauten@sensoryinc.com"
ENV TZ=US/Mountain
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get --fix-missing update
RUN apt-get -y upgrade
RUN apt-get install -y htop nano vim git screen tmux bash
RUN apt-get install -y build-essential clang autoconf libtool gpg pkg-config curl wget zip cmake ninja-build ccache
RUN apt-get install -y libopenblas-dev

# Install the latest version of CMake. This is based on the official CMake
# documentation for Ubuntu 18.04 here: https://apt.kitware.com/
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ bionic main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null
RUN apt-get update
RUN apt-get install -y cmake

# Install python 3.8, the minimum for torch is 3.7
RUN apt-get install -y python3.8 python3.8-distutils python3.8-dev
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3.8 get-pip.py
# Override the symbolic links for python
RUN rm /usr/bin/python
RUN ln -s python3.8 /usr/bin/python
# Override the symbolic links for python 3
RUN rm /usr/bin/python3
RUN ln -s python3.8 /usr/bin/python3
# Cleanup after installing to remove bloat from the image.
RUN apt -y autoremove
RUN apt -y clean

# Copy the PyTorch repository. Because it is a sub-module, we need the host
# git repo as well, otherwise we wont be able to switch branches.
COPY ./build.sh /libtorch-factory/build.sh

# Set the working directory to the head of the repository.
WORKDIR /libtorch-factory
