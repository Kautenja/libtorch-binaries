# Libtorch Binaries

This repository provides tooling for compiling libtorch binaries.

## Binaries

| libtorch | Architecture | OS    | Binary                                |
|:---------|:-------------|:------|:--------------------------------------|
| 1.13.0   | aarch64      | Linux | [download][1_13_0_py38_aarch64_linux] |
| 1.12.0   | aarch64      | Linux | [download][1_12_0_py38_aarch64_linux] |
| 1.11.0   | aarch64      | Linux | [download][1_11_0_py38_aarch64_linux] |
| 1.10.0   | aarch64      | Linux | [download][1_10_0_py38_aarch64_linux] |
| 1.9.0    | aarch64      | Linux | [download][1_9_0_py38_aarch64_linux]  |

<!-- 1.13 -->
[1_13_0_py38_aarch64_linux]: https://github.com/Kautenja/libtorch-binaries/releases/download/v1.0.0/libtorch-shared-with-deps-aarch64-linux-1.13.0.zip
<!-- 1.12 -->
[1_12_0_py38_aarch64_linux]: https://github.com/Kautenja/libtorch-binaries/releases/download/v1.0.0/libtorch-shared-with-deps-aarch64-linux-1.12.0.zip
<!-- 1.11 -->
[1_11_0_py38_aarch64_linux]: https://github.com/Kautenja/libtorch-binaries/releases/download/v1.0.0/libtorch-shared-with-deps-aarch64-linux-1.11.0.zip
<!-- 1.10 -->
[1_10_0_py38_aarch64_linux]: https://github.com/Kautenja/libtorch-binaries/releases/download/v1.0.0/libtorch-shared-with-deps-aarch64-linux-1.10.0.zip
<!-- 1.9 -->
[1_9_0_py38_aarch64_linux]: https://github.com/Kautenja/libtorch-binaries/releases/download/v1.0.0/libtorch-shared-with-deps-aarch64-linux-1.9.0.zip

## Usage

### Image generation

Cross-compilation in this project is conducted within Docker containers to
simplify the sand-boxing of system libraries, such as GLIBC.
[dockerfiles](dockerfiles) contains Dockerfiles catered to various operating
systems (and the associated compilers that they typically ship with.) To
generate the images, ensure your Docker daemon is running and execute

```shell
./main.sh dockerbuild
```

or

```shell
docker compose build --parallel
```

to build the images following the recipes from the
[docker-compose.yaml](docker-compose.yaml) file. For reference, the current
images ordered by operating system and version are:

| Operating System | GLIBCXX | GLIBC | Python | Docker image tag             |
|:-----------------|:--------|:------|:-------|:-----------------------------|
| Ubuntu 22.04     | 3.4.30  | 2.35  | 3.10   | libtorch-factory:Ubuntu22.04 |
| Ubuntu 20.04     | 3.4.28  | 2.31  | 3.8    | libtorch-factory:Ubuntu20.04 |
| Ubuntu 18.04     | 3.4.25  | 2.27  | 3.8    | libtorch-factory:Ubuntu18.04 |

If you have a need for a particular operating system that is not listed, or a
specific version of GLIB, please open an issue!

To determine the version of GLIBCXX used by your system, use something like
the following (where `aarch64-linux-gnu` is replaced depending on the machine.)

```shell
strings /usr/lib/aarch64-linux-gnu/libstdc++.so.6 | grep GLIBCXX
```

For x86 Linux one would use:

```shell
strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 | grep GLIBCXX
```

To determine the version of GLIBC used by your system, use `ldd --version`.

### Library compilation

Once at least one docker image has been generated, libtorch may be compiled
within the container. It's worth noting that you will need to run your image
on the target CPU architecture on which you intend to compile your final
product. For instance, if you are deploying code to an ARM platform, you will
need to compile libtorch from a similar ARM platform (not an x86_64 platform.)

To compile libtorch, simply run the following subbing `<IMAGE>` for one of the
Docker image tags in the above table.

```shell
./main.sh <IMAGE> build
```

For instance, to compile on `Ubuntu22.04`, one would use

```shell
./main.sh libtorch-factory:Ubuntu22.04 build
```

The build routine will dump the C++ library and a Python wheel to the local
[build](build) directory.

To build for a specific version of PyTorch, one can use:

```shell
./main.sh <IMAGE> "PYTORCH_VERSION=<VERSION> ./build.sh"
```

For instance, to compile `1.13.0` on `Ubuntu22.04`, one would use:

```shell
./main.sh libtorch-factory:Ubuntu22.04 "PYTORCH_VERSION=1.13.0 ./build.sh"
```

If more exotic modifications need to be made, one can open an interactive shell
session within the container using:

```shell
./main.sh <IMAGE> bash
```

#### Compilation outside of a container

If you would prefer to directly compile libtorch outside of a Docker container,
this can be accomplished using:

```shell
./build.sh
```

The build routine will dump the C++ library and a Python wheel to the local
[build](build) directory.

**N.B.:** Because the build script will alter your python environment, it is
recommended to first create a virtual environment and source the terminal
before launching the build script.

### Packaging this repository

If you need to zip this repository up to move it to a machine, this can be
accomplished using:

```shell
./main.sh package
```
