#ifndef WIREGUARD_FLUTTER_SERVICE_CONTROL_H
#define WIREGUARD_FLUTTER_SERVICE_CONTROL_H

#include <flutter/standard_method_codec.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/encodable_value.h>

#include <string>
#include <memory>

namespace wireguard_flutter {

struct CreateArgs {
  std::wstring description, executable_and_args, dependencies;
  bool first_time;
};

struct WireGuardStatistics {
  uint64_t rx_bytes;
  uint64_t tx_bytes;
  int64_t last_handshake; // Unix timestamp in seconds
};

class ServiceControl {
 public:
  std::wstring service_name_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> events_;

  ServiceControl(const std::wstring service_name) : service_name_(service_name) {}

  void CreateAndStart(CreateArgs args);
  void Stop();
  std::string GetStatus();
  bool is_running();
  WireGuardStatistics get_statistics();
  void RegisterListener(std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events);
  void UnregisterListener();
  void EmitState(std::string state);
};

}  // namespace wireguard_flutter

#endif
