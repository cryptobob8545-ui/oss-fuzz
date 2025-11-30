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
  -Dprotobuf_ABSL_PROVIDER=module \
  -Dprotobuf_BUILD_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo

cmake --build "$BUILD_DIR" -j"$(nproc)"

# Locate static libprotobuf; this may need adjustment if upstream layout changes.
LIBPROTOBUF=$(find "$BUILD_DIR" -name 'libprotobuf.a' | head -n 1 || true)
if [[ -z "$LIBPROTOBUF" ]]; then
  echo "libprotobuf.a not found in build tree"
  exit 1
fi
# utf8_range library used by protobuf UTF-8 validation.
LIBUTF8=$(find "$BUILD_DIR" -name 'libutf8_range.a' | head -n 1 || true)
if [[ -z "$LIBUTF8" ]]; then
  echo "libutf8_range.a not found in build tree"
  exit 1
fi

# Collect absl static libs to satisfy protobuf's absl dependencies.
ABSL_LIBS=$(find "$BUILD_DIR/_deps/absl-build" -name 'libabsl_*.a' | tr '\n' ' ')

# Build the fuzzer.
cd "$SRC"
$CXX $CXXFLAGS -std=c++17 \
  -I"$PROJECT_SRC/src" \
  -I"$BUILD_DIR/_deps/absl-src" \
  -I"$BUILD_DIR/_deps/absl-build" \
  -I"$PROJECT_SRC/third_party/utf8_range" \
  protobuf_message_fuzzer.cc \
  -Wl,--start-group \
  "$LIBPROTOBUF" \
  $ABSL_LIBS \
  "$LIBUTF8" \
  -Wl,--end-group \
  -lpthread -lz \
  $LIB_FUZZING_ENGINE \
  -o "$OUT/protobuf_message_fuzzer"
