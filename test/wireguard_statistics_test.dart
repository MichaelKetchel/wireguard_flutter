import 'package:flutter_test/flutter_test.dart';
import 'package:wireguard_flutter/wireguard_statistics.dart';

void main() {
  group('WireGuardStatistics', () {
    test('should create instance with required parameters', () {
      const stats = WireGuardStatistics(
        rxBytes: 1024,
        txBytes: 2048,
        isConnected: true,
      );

      expect(stats.rxBytes, equals(1024));
      expect(stats.txBytes, equals(2048));
      expect(stats.isConnected, equals(true));
      expect(stats.lastHandshake, isNull);
      expect(stats.totalBytes, equals(3072));
    });

    test('should create instance with all parameters', () {
      final handshakeTime = DateTime.now();
      final stats = WireGuardStatistics(
        rxBytes: 500,
        txBytes: 1500,
        lastHandshake: handshakeTime,
        isConnected: true,
      );

      expect(stats.rxBytes, equals(500));
      expect(stats.txBytes, equals(1500));
      expect(stats.lastHandshake, equals(handshakeTime));
      expect(stats.isConnected, equals(true));
      expect(stats.totalBytes, equals(2000));
    });

    test('should create instance from map', () {
      final handshakeTime = DateTime.fromMillisecondsSinceEpoch(1640995200000); // Fixed timestamp
      final map = {
        'rxBytes': 1000,
        'txBytes': 2000,
        'lastHandshake': handshakeTime.millisecondsSinceEpoch,
        'isConnected': true,
      };

      final stats = WireGuardStatistics.fromMap(map);

      expect(stats.rxBytes, equals(1000));
      expect(stats.txBytes, equals(2000));
      expect(stats.lastHandshake, equals(handshakeTime));
      expect(stats.isConnected, equals(true));
    });

    test('should handle null values in fromMap', () {
      final map = <String, dynamic>{
        'rxBytes': null,
        'txBytes': null,
        'lastHandshake': null,
        'isConnected': null,
      };

      final stats = WireGuardStatistics.fromMap(map);

      expect(stats.rxBytes, equals(0));
      expect(stats.txBytes, equals(0));
      expect(stats.lastHandshake, isNull);
      expect(stats.isConnected, equals(false));
    });

    test('should handle missing values in fromMap', () {
      final map = <String, dynamic>{};

      final stats = WireGuardStatistics.fromMap(map);

      expect(stats.rxBytes, equals(0));
      expect(stats.txBytes, equals(0));
      expect(stats.lastHandshake, isNull);
      expect(stats.isConnected, equals(false));
    });

    test('should convert to map', () {
      final handshakeTime = DateTime.now();
      final stats = WireGuardStatistics(
        rxBytes: 1000,
        txBytes: 2000,
        lastHandshake: handshakeTime,
        isConnected: true,
      );

      final map = stats.toMap();

      expect(map['rxBytes'], equals(1000));
      expect(map['txBytes'], equals(2000));
      expect(map['lastHandshake'], equals(handshakeTime.millisecondsSinceEpoch));
      expect(map['isConnected'], equals(true));
    });

    test('should convert to map with null handshake', () {
      const stats = WireGuardStatistics(
        rxBytes: 1000,
        txBytes: 2000,
        isConnected: false,
      );

      final map = stats.toMap();

      expect(map['rxBytes'], equals(1000));
      expect(map['txBytes'], equals(2000));
      expect(map['lastHandshake'], isNull);
      expect(map['isConnected'], equals(false));
    });

    test('should calculate total bytes correctly', () {
      const stats = WireGuardStatistics(
        rxBytes: 1024,
        txBytes: 2048,
        isConnected: true,
      );

      expect(stats.totalBytes, equals(3072));
    });

    test('should implement equality correctly', () {
      final handshakeTime = DateTime.now();
      
      final stats1 = WireGuardStatistics(
        rxBytes: 1000,
        txBytes: 2000,
        lastHandshake: handshakeTime,
        isConnected: true,
      );

      final stats2 = WireGuardStatistics(
        rxBytes: 1000,
        txBytes: 2000,
        lastHandshake: handshakeTime,
        isConnected: true,
      );

      final stats3 = WireGuardStatistics(
        rxBytes: 1001,
        txBytes: 2000,
        lastHandshake: handshakeTime,
        isConnected: true,
      );

      expect(stats1, equals(stats2));
      expect(stats1, isNot(equals(stats3)));
    });

    test('should have consistent hashCode for equal objects', () {
      final handshakeTime = DateTime.now();
      
      final stats1 = WireGuardStatistics(
        rxBytes: 1000,
        txBytes: 2000,
        lastHandshake: handshakeTime,
        isConnected: true,
      );

      final stats2 = WireGuardStatistics(
        rxBytes: 1000,
        txBytes: 2000,
        lastHandshake: handshakeTime,
        isConnected: true,
      );

      expect(stats1.hashCode, equals(stats2.hashCode));
    });

    test('should have meaningful toString representation', () {
      final handshakeTime = DateTime.now();
      final stats = WireGuardStatistics(
        rxBytes: 1000,
        txBytes: 2000,
        lastHandshake: handshakeTime,
        isConnected: true,
      );

      final string = stats.toString();

      expect(string, contains('1000'));
      expect(string, contains('2000'));
      expect(string, contains('true'));
      expect(string, contains(handshakeTime.toString()));
    });

    test('should handle type conversion in fromMap', () {
      final map = {
        'rxBytes': 1000.5,  // double instead of int
        'txBytes': '2000',  // string instead of int
        'lastHandshake': 1640995200000.0,  // double instead of int
        'isConnected': 'true',  // string instead of bool
      };

      final stats = WireGuardStatistics.fromMap(map);

      expect(stats.rxBytes, equals(1000));
      expect(stats.txBytes, equals(2000)); // String conversion now works
      expect(stats.lastHandshake, isNotNull);
      expect(stats.isConnected, equals(true)); // String conversion now works
    });
  });
}