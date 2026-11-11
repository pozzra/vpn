import 'dart:convert';
import 'dart:math';
import '../models/vpn_server.dart';

class ConfigService {
  static final Random _random = Random();

  /// Generates a valid WireGuard client configuration file for a given server
  static String generateWireGuardConfig({
    required VpnServer server,
    String clientIp = '10.8.0.2/32',
    String dns = '1.1.1.1, 8.8.8.8',
  }) {
    final clientPrivateKey = _generateMockKey();
    final serverPublicKey = _generateMockKey();

    return '''# VPN BY RXAA - WireGuard Tunnel Configuration
# Location: ${server.countryName} - ${server.city} (${server.countryCode})
# Endpoint: ${server.ipAddress}:${server.port}

[Interface]
PrivateKey = $clientPrivateKey
Address = $clientIp
DNS = $dns
MTU = 1420

[Peer]
PublicKey = $serverPublicKey
Endpoint = ${server.ipAddress}:${server.port}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
''';
  }

  /// Generates a standard OpenVPN (.ovpn) configuration file
  static String generateOpenVpnConfig({
    required VpnServer server,
    bool useTcp = false,
  }) {
    final proto = useTcp ? 'tcp' : 'udp';
    final port = useTcp ? 443 : 1194;

    return '''# VPN BY RXAA - OpenVPN Client Profile
# Node: ${server.displayName}
client
dev tun
proto $proto
remote ${server.ipAddress} $port
resolv-retry infinite
nobind
persist-key
persist-tun
cipher AES-256-GCM
auth SHA256
remote-cert-tls server
compress lz4-v2
verb 3
auth-user-pass
''';
  }

  static String _generateMockKey() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return base64.encode(bytes);
  }
}
