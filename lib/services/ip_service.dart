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
  static const String _defaultOriginalIp = '104.28.19.124';

  static Future<IpInfo> fetchPublicIp({VpnServer? connectedServer}) async {
    if (connectedServer != null) {
      // Return VPN protected IP state
      return IpInfo(
        ip: connectedServer.ipAddress,
        country: connectedServer.countryName,
        countryCode: connectedServer.countryCode,
        city: connectedServer.city,
        isp: 'VPN One Secure Tunnel (Mullvad / Cloudflare Backbone)',
        org: 'AS13335 VPN One Network Corp',
        timezone: 'UTC',
        lat: 37.7749,
        lon: -122.4194,
        isProtected: true,
      );
    }

    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ip = data['ip'] as String? ?? _defaultOriginalIp;
        return IpInfo(
          ip: ip,
          country: 'Local Network',
          countryCode: 'LOC',
          city: 'Your City',
          isp: 'Local ISP Telecom',
          org: 'Residential Gateway',
          timezone: 'Local Time',
          lat: 0.0,
          lon: 0.0,
          isProtected: false,
        );
      }
    } catch (_) {
      // Fallback
    }

    return IpInfo(
      ip: _defaultOriginalIp,
      country: 'Unprotected Gateway',
      countryCode: 'UNP',
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

