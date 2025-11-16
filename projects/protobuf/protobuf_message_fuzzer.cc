#include <cstdint>
#include <cstddef>

#include "google/protobuf/descriptor.pb.h"

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
  google::protobuf::DescriptorProto proto;
  // Ignore parse result; we're interested in exercising parsing logic.
  proto.ParseFromArray(data, static_cast<int>(size));
  return 0;
}

