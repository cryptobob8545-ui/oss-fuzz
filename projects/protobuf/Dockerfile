# Simple OSS-Fuzz style setup for protobuf C++.
#
# This is intended for local Buttercup testing, not upstream oss-fuzz.

FROM gcr.io/oss-fuzz-base/base-builder

RUN apt-get update && \
    apt-get install -y cmake make autoconf automake libtool pkg-config zlib1g-dev

# Clone upstream protobuf and its Abseil dependency; Buttercup will swap in
# the challenge repo when running tasks.
RUN git clone --depth 1 https://github.com/protocolbuffers/protobuf.git $SRC/protobuf
RUN git clone --depth 1 https://github.com/abseil/abseil-cpp.git $SRC/protobuf/third_party/abseil-cpp

WORKDIR $SRC/protobuf

# Copy build script and fuzzer into place.
COPY build.sh protobuf_message_fuzzer.cc $SRC/
