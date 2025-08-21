import 'wireguard_statistics.dart';

abstract class WireGuardFlutterInterface {
  Stream<VpnStage> get vpnStageSnapshot;

  Future<void> initialize({required String interfaceName});

  Future<void> startVpn({
    required String serverAddress,
    required String wgQuickConfig,
    required String providerBundleIdentifier,
  });

  Future<void> stopVpn();
  Future<void> checkPermission();
  
  /// Get comprehensive statistics including transfer data and last handshake
  Future<WireGuardStatistics> getStatistics();
  
  /// Get download data in bytes (for backward compatibility)
  Future<int> getDownloadData();
  
  /// Get upload data in bytes (for backward compatibility)
  Future<int> getUploadData();
  
  /// Get transfer data in bytes (for backward compatibility)
  Future<int> getTransferData();
  
  /// Get the timestamp of the last handshake with the peer
  Future<DateTime?> getLastHandshake();

  Future<void> refreshStage();
  Future<VpnStage> stage();
  Future<bool> isConnected() =>
      stage().then((stage) => stage == VpnStage.connected);
}

enum VpnStage {
  connected('connected'),
  connecting('connecting'),
  disconnecting('disconnecting'),
  disconnected('disconnected'),
  waitingConnection('wait_connection'),
  authenticating('authenticating'),
  reconnect('reconnect'),
  noConnection('no_connection'),
  preparing('prepare'),
  denied('denied'),
  exiting('exiting');

  final String code;

  const VpnStage(this.code);
}
