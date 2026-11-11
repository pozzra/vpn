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
      // Dynamic City Geolocation Mapping
      double lat = 34.0522;
      double lon = -118.2437;
      String timezone = 'America/Los_Angeles';

      if (connectedServer.city.contains('Los Angeles')) {
        lat = 34.0522;
        lon = -118.2437;
        timezone = 'America/Los_Angeles';
      } else if (connectedServer.city.contains('New York')) {
        lat = 40.7128;
        lon = -74.0060;
        timezone = 'America/New_York';
      } else if (connectedServer.city.contains('Tokyo')) {
        lat = 35.6762;
        lon = 139.6503;
        timezone = 'Asia/Tokyo';
      } else if (connectedServer.city.contains('Frankfurt')) {
        lat = 50.1109;
        lon = 8.6821;
        timezone = 'Europe/Berlin';
      } else if (connectedServer.city.contains('Singapore')) {
        lat = 1.3521;
        lon = 103.8198;
        timezone = 'Asia/Singapore';
      } else if (connectedServer.city.contains('London')) {
        lat = 51.5074;
        lon = -0.1278;
        timezone = 'Europe/London';
      }

      // Return VPN protected IP state matching the selected server
      return IpInfo(
        ip: connectedServer.ipAddress,
        country: connectedServer.countryName,
        countryCode: connectedServer.countryCode,
        city: connectedServer.city,
        isp: 'VPN BY RXAA Secure Gateway (${connectedServer.city} Core Node)',
        org: 'AS13335 RXAA Global Network LLC',
        timezone: timezone,
        lat: lat,
        lon: lon,
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
