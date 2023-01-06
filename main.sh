#!/bin/sh
#
# Usage main.sh [routine|image] [routine]
#
# Commands:
#     dockerbuild    Build all docker images in parallel
#     package        Package the project into a zip file.
#     [image] build  Build the code for the current platform
#     [image] *      Execute an arbitrary routine interactively in the container
#

# --- Functions --------------------------------------------------------------

# Print the help string at the top of this script.
# Reference: https://josh.fail/2019/how-to-print-help-text-in-shell-scripts/
print_help() {
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0"
}

# --- CLI --------------------------------------------------------------------

# The first CLI offers basic build commands outside of the scope of a container.

case "$1" in
"")
  print_help
  exit 0;
;;
"dockerbuild")
  docker compose build --parallel
  exit 0;
;;
"package")
  zip -r libtorch-factory.zip \
    README.md CHANGELOG.md LICENSE.md \
    build.sh main.sh docker-compose.yaml .dockerignore dockerfiles/*
  exit 0;
;;
esac

# The second CLI commands are formatted as ./main.sh <IMAGE> <COMMAND> <OPTIONS>

IMAGE=$1
COMMAND=$2

case "${COMMAND}" in
"")
  print_help
  exit 0;
;;
"build")
  mkdir -p build
  docker run --rm \
    -v $(pwd)/build:/libtorch-factory/build \
    ${IMAGE} bash -c "./build.sh"
  exit 0;
;;
*)
  mkdir -p build
  docker run --rm -it \
    -v $(pwd)/build:/libtorch-factory/build \
    ${IMAGE} bash -c "${COMMAND}"
  exit 0;
;;
esac
