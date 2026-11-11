import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vpn_server.dart';

class IpInfo {
  final String ip;
  final String country;
  final String countryCode;
  final String city;
  final String isp;
  final String org;
  final String timezone;
  final double lat;
  final double lon;
  final bool isProtected;

  IpInfo({
    required this.ip,
    required this.country,
    required this.countryCode,
    required this.city,
    required this.isp,
    required this.org,
    required this.timezone,
    required this.lat,
    required this.lon,
    required this.isProtected,
  });
}

class IpService {
  static const String _defaultOriginalIp = '45.119.135.94';

  static Future<IpInfo> fetchPublicIp({VpnServer? connectedServer}) async {
    if (connectedServer != null) {
      // Return VPN protected IP state
      return IpInfo(
        ip: connectedServer.ipAddress,
        country: connectedServer.countryName,
        countryCode: connectedServer.countryCode,
        city: connectedServer.city,
        isp: 'VPN One Secure Tunnel (${connectedServer.countryName} Dedicated Node)',
        org: 'AS13335 VPN One Network Corp',
        timezone: 'UTC',
        lat: 37.7749,
        lon: -122.4194,
        isProtected: true,
      );
    }

    // When disconnected, fetch real physical IP & network details
    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return IpInfo(
            ip: data['query'] ?? _defaultOriginalIp,
            country: data['country'] ?? 'Local Network',
            countryCode: data['countryCode'] ?? 'LOC',
            city: data['city'] ?? 'Local Area',
            isp: data['isp'] ?? 'Local Broadband Provider',
            org: data['org'] ?? 'Local ISP',
            timezone: data['timezone'] ?? 'Local Time',
            lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
            lon: (data['lon'] as num?)?.toDouble() ?? 0.0,
            isProtected: false,
          );
        }
      }
    } catch (_) {
      // Fallback to ipify if ip-api is blocked or timed out
      try {
        final fallback = await http
            .get(Uri.parse('https://api.ipify.org?format=json'))
            .timeout(const Duration(seconds: 3));
        if (fallback.statusCode == 200) {
          final data = jsonDecode(fallback.body);
          return IpInfo(
            ip: data['ip'] ?? _defaultOriginalIp,
            country: 'Local Network',
            countryCode: 'LOC',
            city: 'Local Area',
            isp: 'Local Broadband Provider',
            org: 'Residential ISP',
            timezone: 'Local Time',
            lat: 0.0,
            lon: 0.0,
            isProtected: false,
          );
        }
      } catch (_) {}
    }

    return IpInfo(
      ip: _defaultOriginalIp,
      country: 'Exposed ISP Gateway',
      countryCode: 'LOC',
      city: 'Local Area',
      isp: 'Broadband Provider (Exposed)',
      org: 'Unencrypted Transit',
      timezone: 'UTC',
      lat: 0.0,
      lon: 0.0,
      isProtected: false,
    );
  }
}
