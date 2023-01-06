#!/usr/bin/env bash

# The version of libtorch to compile, may be overridden from the command line.
PYTORCH_VERSION=${PYTORCH_VERSION:-1.11.0}
# The architecture of the CPU.
ARCHITECTURE=$(uname -m)
# The kernel name of the operating system.
KERNEL=$(uname -s | awk '{print tolower($0)}')
# Determine the number of logical compute cores on the CPU.
if [[ "$KERNEL" == "darwin" ]]; then
    LOGICAL_CORES=$(sysctl -n hw.logicalcpu)
else
    LOGICAL_CORES=$(nproc --ignore=1)
fi
echo "Compiling v${PYTORCH_VERSION} for ${ARCHITECTURE}-${KERNEL} using ${LOGICAL_CORES} cores"

# The output zipfile for the compiled code.
LIBRARY_FILENAME=libtorch-shared-with-deps-${ARCHITECTURE}-${KERNEL}-${PYTORCH_VERSION}.zip
echo "Will save artifacts to: ${LIBRARY_FILENAME}"

# Create the build directory first in case there are file-system issues.
mkdir -p build
mkdir -p pytorch-build
# Clone PyTorch (this can be slow depending on internet connection.)
git clone -b v${PYTORCH_VERSION} --recurse-submodule https://github.com/pytorch/pytorch.git
# Install the necessary python requirements
pip install setuptools==59.5.0
pip install -qr pytorch/requirements.txt
# Move into the build directory and compile the library.
cd pytorch-build
cmake -DBUILD_SHARED_LIBS:BOOL=ON -DCMAKE_BUILD_TYPE:STRING=Release -DPYTHON_EXECUTABLE:PATH=`which python3` -DCMAKE_INSTALL_PREFIX:PATH=../libtorch ../pytorch
cmake --build . --target install -j${LOGICAL_CORES}

# Zip the code into the build directory.
cd ../
zip -r ./build/${LIBRARY_FILENAME} libtorch
