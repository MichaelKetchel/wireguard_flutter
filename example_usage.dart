// Example usage of the new WireGuard statistics features
import 'package:wireguard_flutter/wireguard_flutter.dart';

class WireGuardStatisticsExample {
  
  /// Example of how to get comprehensive statistics
  Future<void> showStatistics() async {
    try {
      // Get comprehensive statistics
      final stats = await WireGuardFlutter.instance.getStatistics();
      
      print('=== WireGuard Statistics ===');
      print('Connected: ${stats.isConnected}');
      print('Downloaded: ${formatBytes(stats.rxBytes)}');
      print('Uploaded: ${formatBytes(stats.txBytes)}');
      print('Total: ${formatBytes(stats.totalBytes)}');
      
      if (stats.lastHandshake != null) {
        print('Last handshake: ${stats.lastHandshake}');
        print('Time since handshake: ${DateTime.now().difference(stats.lastHandshake!)}');
      } else {
        print('Last handshake: Never');
      }
    } catch (e) {
      print('Error getting statistics: $e');
    }
  }
  
  /// Example of how to get individual metrics (backward compatibility)
  Future<void> showIndividualMetrics() async {
    try {
      // Get individual metrics
      final downloadBytes = await WireGuardFlutter.instance.getDownloadData();
      final uploadBytes = await WireGuardFlutter.instance.getUploadData();
      final totalBytes = await WireGuardFlutter.instance.getTransferData();
      final lastHandshake = await WireGuardFlutter.instance.getLastHandshake();
      
      print('=== Individual Metrics ===');
      print('Download: ${formatBytes(downloadBytes)}');
      print('Upload: ${formatBytes(uploadBytes)}');
      print('Total: ${formatBytes(totalBytes)}');
      print('Last handshake: ${lastHandshake ?? "Never"}');
    } catch (e) {
      print('Error getting individual metrics: $e');
    }
  }
  
  /// Example of how to monitor statistics in real-time
  Future<void> monitorStatistics() async {
    print('=== Starting Statistics Monitor ===');
    
    // Monitor statistics every 5 seconds
    while (true) {
      try {
        final stats = await WireGuardFlutter.instance.getStatistics();
        
        if (stats.isConnected) {
          print('[${DateTime.now()}] '
                'RX: ${formatBytes(stats.rxBytes)}, '
                'TX: ${formatBytes(stats.txBytes)}, '
                'Handshake: ${stats.lastHandshake?.toString() ?? "Never"}');
        } else {
          print('[${DateTime.now()}] VPN not connected');
        }
        
        await Future.delayed(const Duration(seconds: 5));
      } catch (e) {
        print('Error monitoring statistics: $e');
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }
  
  /// Helper function to format bytes in human-readable format
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Example of complete VPN lifecycle with statistics
  Future<void> vpnLifecycleExample() async {
    try {
      // Initialize
      await WireGuardFlutter.instance.initialize(interfaceName: 'MyVPN');
      
      // Check permissions
      await WireGuardFlutter.instance.checkPermission();
      
      // Start VPN
      await WireGuardFlutter.instance.startVpn(
        serverAddress: 'your.vpn.server.com',
        wgQuickConfig: '''
[Interface]
PrivateKey = your_private_key
Address = 10.0.0.2/24

[Peer]
PublicKey = server_public_key
Endpoint = your.vpn.server.com:51820
AllowedIPs = 0.0.0.0/0
''',
        providerBundleIdentifier: 'com.yourapp.vpn',
      );
      
      // Wait a bit for connection to establish
      await Future.delayed(const Duration(seconds: 3));
      
      // Show initial statistics
      await showStatistics();
      
      // Monitor for a minute
      final stopTime = DateTime.now().add(const Duration(minutes: 1));
      while (DateTime.now().isBefore(stopTime)) {
        await showStatistics();
        await Future.delayed(const Duration(seconds: 10));
      }
      
      // Stop VPN
      await WireGuardFlutter.instance.stopVpn();
      
      // Show final statistics
      await showStatistics();
      
    } catch (e) {
      print('Error in VPN lifecycle: $e');
    }
  }
}

// Usage example
void main() async {
  final example = WireGuardStatisticsExample();
  
  // Show current statistics
  await example.showStatistics();
  
  // Show individual metrics
  await example.showIndividualMetrics();
  
  // For real-time monitoring (uncomment to use):
  // await example.monitorStatistics();
  
  // For complete lifecycle test (uncomment and configure):
  // await example.vpnLifecycleExample();
}