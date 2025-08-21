import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

import '../wireguard_flutter_platform_interface.dart';
import '../wireguard_statistics.dart';

class WireGuardFlutterLinux extends WireGuardFlutterInterface {
  String? name;
  File? configFile;

  VpnStage _stage = VpnStage.noConnection;
  final _stageController = StreamController<VpnStage>.broadcast();
  void _setStage(VpnStage stage) {
    _stage = stage;
    _stageController.add(stage);
  }

  final shell = Shell(runInShell: true, verbose: kDebugMode);

  @override
  Future<void> initialize({required String interfaceName}) async {
    name = interfaceName.replaceAll(' ', '_');
    await refreshStage();
  }

  Future<String> get filePath async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}${Platform.pathSeparator}$name.conf';
  }

  @override
  Future<void> startVpn({
    required String serverAddress,
    required String wgQuickConfig,
    required String providerBundleIdentifier,
  }) async {
    final isAlreadyConnected = await isConnected();
    if (!isAlreadyConnected) {
      _setStage(VpnStage.preparing);
    } else {
      debugPrint('Already connected');
    }

    try {
      configFile = await File(await filePath).create();
      await configFile!.writeAsString(wgQuickConfig);
    } on PathAccessException {
      debugPrint('Denied to write file. Trying to start interface');
      if (isAlreadyConnected) {
        return _setStage(VpnStage.connected);
      }

      try {
        await shell.run('sudo wg-quick up $name');
      } catch (_) {
      } finally {
        _setStage(VpnStage.denied);
      }
    }

    if (!isAlreadyConnected) {
      _setStage(VpnStage.connecting);
      await shell.run('sudo wg-quick up ${configFile?.path ?? await filePath}');
      _setStage(VpnStage.connected);
    }
  }

  @override
  Future<void> stopVpn() async {
    assert(
      (await isConnected()),
      'Bad state: vpn has not been started. Call startVpn',
    );
    _setStage(VpnStage.disconnecting);
    try {
      await shell
          .run('sudo wg-quick down ${configFile?.path ?? (await filePath)}');
    } catch (e) {
      await refreshStage();
      rethrow;
    }
    await refreshStage();
  }

  @override
  Future<VpnStage> stage() async => _stage;

  @override
  Stream<VpnStage> get vpnStageSnapshot => _stageController.stream;

  @override
  Future<void> refreshStage() async {
    if (await isConnected()) {
      _setStage(VpnStage.connected);
    } else if (name == null) {
      _setStage(VpnStage.waitingConnection);
    } else if (configFile == null) {
      _setStage(VpnStage.noConnection);
    } else {
      _setStage(VpnStage.disconnected);
    }
  }

  @override
  Future<bool> isConnected() async {
    assert(
      name != null,
      'Bad state: not initialized. Call "initialize" before calling this command',
    );
    final processResultList = await shell.run('sudo wg');
    final process = processResultList.first;
    return process.outLines.any((line) => line.trim() == 'interface: $name');
  }

  @override
  Future<WireGuardStatistics> getStatistics() async {
    if (name == null || !await isConnected()) {
      return const WireGuardStatistics(
        rxBytes: 0,
        txBytes: 0,
        isConnected: false,
      );
    }

    try {
      // Get transfer data
      final transferResult = await shell.run('sudo wg show $name transfer');
      final handshakeResult = await shell.run('sudo wg show $name latest-handshakes');
      
      int rxBytes = 0;
      int txBytes = 0;
      DateTime? lastHandshake;

      // Parse transfer data
      if (transferResult.isNotEmpty) {
        final transferOutput = transferResult.first.outText;
        final lines = transferOutput.split('\n');
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            final parts = line.trim().split(RegExp(r'\s+'));
            if (parts.length >= 3) {
              // Format: peer_public_key  received_bytes  sent_bytes
              final rx = int.tryParse(parts[1]) ?? 0;
              final tx = int.tryParse(parts[2]) ?? 0;
              rxBytes += rx;
              txBytes += tx;
            }
          }
        }
      }

      // Parse handshake data
      if (handshakeResult.isNotEmpty) {
        final handshakeOutput = handshakeResult.first.outText;
        final lines = handshakeOutput.split('\n');
        int latestTimestamp = 0;
        
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            final parts = line.trim().split(RegExp(r'\s+'));
            if (parts.length >= 2) {
              // Format: peer_public_key  unix_timestamp
              final timestamp = int.tryParse(parts[1]) ?? 0;
              if (timestamp > latestTimestamp) {
                latestTimestamp = timestamp;
              }
            }
          }
        }
        
        if (latestTimestamp > 0) {
          lastHandshake = DateTime.fromMillisecondsSinceEpoch(latestTimestamp * 1000);
        }
      }

      return WireGuardStatistics(
        rxBytes: rxBytes,
        txBytes: txBytes,
        lastHandshake: lastHandshake,
        isConnected: true,
      );
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return const WireGuardStatistics(
        rxBytes: 0,
        txBytes: 0,
        isConnected: false,
      );
    }
  }

  @override
  Future<int> getDownloadData() async {
    final stats = await getStatistics();
    return stats.rxBytes;
  }

  @override
  Future<int> getUploadData() async {
    final stats = await getStatistics();
    return stats.txBytes;
  }

  @override
  Future<int> getTransferData() async {
    final stats = await getStatistics();
    return stats.totalBytes;
  }

  @override
  Future<DateTime?> getLastHandshake() async {
    final stats = await getStatistics();
    return stats.lastHandshake;
  }

  @override
  Future<void> checkPermission() async {
    // On Linux, permissions are typically handled through sudo
    // We can check if wg command is available
    try {
      await shell.run('which wg');
    } catch (e) {
      throw Exception('WireGuard tools not found. Please install wireguard-tools package.');
    }
  }
}
