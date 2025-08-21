/// Statistics data model for WireGuard connection metrics
class WireGuardStatistics {
  /// Number of bytes received (downloaded)
  final int rxBytes;
  
  /// Number of bytes transmitted (uploaded)
  final int txBytes;
  
  /// Last handshake time with the peer
  final DateTime? lastHandshake;
  
  /// Whether the VPN is currently connected
  final bool isConnected;
  
  const WireGuardStatistics({
    required this.rxBytes,
    required this.txBytes,
    this.lastHandshake,
    required this.isConnected,
  });
  
  /// Creates a WireGuardStatistics instance from a platform channel map
  factory WireGuardStatistics.fromMap(Map<String, dynamic> map) {
    // Safe conversion functions
    int safeIntConversion(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    bool safeBoolConversion(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is num) return value != 0;
      return false;
    }
    
    DateTime? safeDateTimeConversion(dynamic value) {
      if (value == null) return null;
      try {
        if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
        if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
        if (value is String) {
          final timestamp = int.tryParse(value);
          return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
        }
      } catch (e) {
        return null;
      }
      return null;
    }
    
    return WireGuardStatistics(
      rxBytes: safeIntConversion(map['rxBytes']),
      txBytes: safeIntConversion(map['txBytes']),
      lastHandshake: safeDateTimeConversion(map['lastHandshake']),
      isConnected: safeBoolConversion(map['isConnected']),
    );
  }
  
  /// Converts this instance to a map for platform channel communication
  Map<String, dynamic> toMap() {
    return {
      'rxBytes': rxBytes,
      'txBytes': txBytes,
      'lastHandshake': lastHandshake?.millisecondsSinceEpoch,
      'isConnected': isConnected,
    };
  }
  
  /// Total bytes transferred (rx + tx)
  int get totalBytes => rxBytes + txBytes;
  
  @override
  String toString() {
    return 'WireGuardStatistics(rxBytes: $rxBytes, txBytes: $txBytes, '
           'lastHandshake: $lastHandshake, isConnected: $isConnected)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WireGuardStatistics &&
        other.rxBytes == rxBytes &&
        other.txBytes == txBytes &&
        other.lastHandshake == lastHandshake &&
        other.isConnected == isConnected;
  }
  
  @override
  int get hashCode {
    return rxBytes.hashCode ^
        txBytes.hashCode ^
        lastHandshake.hashCode ^
        isConnected.hashCode;
  }
}