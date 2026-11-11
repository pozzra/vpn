import 'vpn_server.dart';

enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

class VpnSessionState {
  final VpnStatus status;
  final VpnServer? currentServer;
  final Duration duration;
  final int bytesIn;
  final int bytesOut;
  final double downloadSpeedKbps;
  final double uploadSpeedKbps;
  final String originalPublicIp;
  final String? assignedVpnIp;
  final String protocol;
  final bool killSwitchEnabled;
  final bool autoConnectEnabled;
  final String dnsServer;
  final bool splitTunnelingEnabled;

  const VpnSessionState({
    this.status = VpnStatus.disconnected,
    this.currentServer,
    this.duration = Duration.zero,
    this.bytesIn = 0,
    this.bytesOut = 0,
    this.downloadSpeedKbps = 0.0,
    this.uploadSpeedKbps = 0.0,
    this.originalPublicIp = '104.28.19.124',
    this.assignedVpnIp,
    this.protocol = 'WireGuard (Fastest)',
    this.killSwitchEnabled = true,
    this.autoConnectEnabled = false,
    this.dnsServer = 'Cloudflare (1.1.1.1)',
    this.splitTunnelingEnabled = false,
  });

  bool get isConnected => status == VpnStatus.connected;
  bool get isConnecting => status == VpnStatus.connecting;
  bool get isDisconnected => status == VpnStatus.disconnected;

  VpnSessionState copyWith({
    VpnStatus? status,
    VpnServer? currentServer,
    Duration? duration,
    int? bytesIn,
    int? bytesOut,
    double? downloadSpeedKbps,
    double? uploadSpeedKbps,
    String? originalPublicIp,
    String? assignedVpnIp,
    String? protocol,
    bool? killSwitchEnabled,
    bool? autoConnectEnabled,
    String? dnsServer,
    bool? splitTunnelingEnabled,
  }) {
    return VpnSessionState(
      status: status ?? this.status,
      currentServer: currentServer ?? this.currentServer,
      duration: duration ?? this.duration,
      bytesIn: bytesIn ?? this.bytesIn,
      bytesOut: bytesOut ?? this.bytesOut,
      downloadSpeedKbps: downloadSpeedKbps ?? this.downloadSpeedKbps,
      uploadSpeedKbps: uploadSpeedKbps ?? this.uploadSpeedKbps,
      originalPublicIp: originalPublicIp ?? this.originalPublicIp,
      assignedVpnIp: assignedVpnIp ?? this.assignedVpnIp,
      protocol: protocol ?? this.protocol,
      killSwitchEnabled: killSwitchEnabled ?? this.killSwitchEnabled,
      autoConnectEnabled: autoConnectEnabled ?? this.autoConnectEnabled,
      dnsServer: dnsServer ?? this.dnsServer,
      splitTunnelingEnabled: splitTunnelingEnabled ?? this.splitTunnelingEnabled,
    );
  }
}

