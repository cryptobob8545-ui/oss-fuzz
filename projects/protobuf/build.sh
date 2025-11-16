#!/bin/bash -eu

# Basic build script for protobuf C++ + a single fuzzer.
# Designed for local Buttercup usage.

PROJECT_SRC="$SRC/protobuf"
BUILD_DIR="$PROJECT_SRC/build"

mkdir -p "$BUILD_DIR"

cd "$PROJECT_SRC"

cmake -S . -B "$BUILD_DIR" \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -Dprotobuf_BUILD_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo

cmake --build "$BUILD_DIR" -j"$(nproc)"

# Locate static libprotobuf; this may need adjustment if upstream layout changes.
LIBPROTOBUF=$(find "$BUILD_DIR" -name 'libprotobuf.a' | head -n 1 || true)
if [[ -z "$LIBPROTOBUF" ]]; then
  echo "libprotobuf.a not found in build tree"
  exit 1
fi

# Build the fuzzer.
cd "$SRC"
$CXX $CXXFLAGS -std=c++17 \
  -I"$PROJECT_SRC/src" \
  protobuf_message_fuzzer.cc \
  "$LIBPROTOBUF" \
  -lpthread -lz \
  $LIB_FUZZING_ENGINE \
  -o "$OUT/protobuf_message_fuzzer"

