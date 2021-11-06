FROM ubuntu:focal AS preinstall

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
    && apt-get install -y \
        cmake \
        curl \
        git \
        lsb-release \
        pkg-config \
        software-properties-common \
        wget \
        zip \
    && rm -rf /var/lib/apt/lists/*


FROM preinstall AS install-clang

ARG LLVM_VERSION=13

RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" "" ${LLVM_VERSION} \
    && rm -rf /var/lib/apt/lists/*

ENV CC=clang-${LLVM_VERSION}
ENV CXX=clang++-${LLVM_VERSION}


FROM install-clang AS install-vcpkg

ENV SLANG_VCPKG_PATH=/vcpkg

WORKDIR /SLang-Codegen-LLVM/
COPY vcpkg.json vcpkg.json
RUN git clone https://github.com/microsoft/vcpkg ${SLANG_VCPKG_PATH} \
    && ${SLANG_VCPKG_PATH}/bootstrap-vcpkg.sh \
    && ${SLANG_VCPKG_PATH}/vcpkg install --clean-after-build


FROM install-vcpkg AS configure-cmake

WORKDIR /SLang-Codegen-LLVM/
COPY CMakeLists.txt CMakeLists.txt
COPY app/ app/
COPY include/ include/
COPY src/ src/
RUN cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=${SLANG_VCPKG_PATH}/scripts/buildsystems/vcpkg.cmake


FROM configure-cmake AS build

RUN cmake --build build --target SlangCompilerLlvmCodegenDriver --config Debug


FROM preinstall AS install

COPY --from=build /SLang-Codegen-LLVM/build/app/SlangCompilerLlvmCodegenDriver /usr/local/bin/SlangCompilerLlvmCodegenDriver
ENTRYPOINT [ "SlangCompilerLlvmCodegenDriver" ]
