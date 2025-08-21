import 'package:flutter/services.dart';

import 'wireguard_flutter_platform_interface.dart';
import 'wireguard_statistics.dart';

class WireGuardFlutterMethodChannel extends WireGuardFlutterInterface {
  static const _methodChannelVpnControl =
      "billion.group.wireguard_flutter/wgcontrol";
  static const _methodChannel = MethodChannel(_methodChannelVpnControl);
  static const _eventChannelVpnStage =
      'billion.group.wireguard_flutter/wgstage';
  static const _eventChannel = EventChannel(_eventChannelVpnStage);

  @override
  Stream<VpnStage> get vpnStageSnapshot =>
      _eventChannel.receiveBroadcastStream().map(
            (event) => event == VpnStage.denied.code
                ? VpnStage.disconnected
                : VpnStage.values.firstWhere(
                    (stage) => stage.code == event,
                    orElse: () => VpnStage.noConnection,
                  ),
          );

  @override
  Future<void> initialize({required String interfaceName}) {
    return _methodChannel.invokeMethod("initialize", {
      "localizedDescription": interfaceName,
      "win32ServiceName": interfaceName,
    });
  }

  @override
  Future<void> startVpn({
    required String serverAddress,
    required String wgQuickConfig,
    required String providerBundleIdentifier,
  }) async {
    return _methodChannel.invokeMethod("start", {
      "serverAddress": serverAddress,
      "wgQuickConfig": wgQuickConfig,
      "providerBundleIdentifier": providerBundleIdentifier,
    });
  }

  @override
  Future<void> stopVpn() => _methodChannel.invokeMethod('stop');

  @override
  Future<void> refreshStage() => _methodChannel.invokeMethod("refresh");

  @override
  Future<VpnStage> stage() => _methodChannel.invokeMethod("stage").then(
        (value) => value != null
            ? VpnStage.values.firstWhere(
                (stage) => stage.code == value.toString(),
                orElse: () => VpnStage.disconnected,
              )
            : VpnStage.disconnected,
      );

  @override
  Future<WireGuardStatistics> getStatistics() async {
    try {
      final Map<String, dynamic>? result = 
          await _methodChannel.invokeMethod('getStatistics');
      if (result == null) {
        return const WireGuardStatistics(
          rxBytes: 0,
          txBytes: 0,
          isConnected: false,
        );
      }
      return WireGuardStatistics.fromMap(Map<String, dynamic>.from(result));
    } catch (e) {
      return const WireGuardStatistics(
        rxBytes: 0,
        txBytes: 0,
        isConnected: false,
      );
    }
  }

  @override
  Future<int> getDownloadData() async {
    try {
      final int? result = await _methodChannel.invokeMethod('getDownloadData');
      return result ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getUploadData() async {
    try {
      final int? result = await _methodChannel.invokeMethod('getUploadData');
      return result ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getTransferData() async {
    try {
      final int? result = await _methodChannel.invokeMethod('getTransferData');
      return result ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<DateTime?> getLastHandshake() async {
    try {
      final int? timestamp = await _methodChannel.invokeMethod('getLastHandshake');
      return timestamp != null && timestamp > 0
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> checkPermission() async {
    try {
      await _methodChannel.invokeMethod('checkPermission');
    } catch (e) {
      // Ignore errors for now
    }
  }
}
