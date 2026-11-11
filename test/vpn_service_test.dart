import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_one/data/country_dataset.dart';
import 'package:vpn_one/models/vpn_server.dart';
import 'package:vpn_one/models/vpn_session.dart';
import 'package:vpn_one/services/storage_service.dart';
import 'package:vpn_one/services/vpn_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VPN One Service and Dataset Tests', () {
    late StorageService storage;
    late VpnService vpnService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await StorageService.init();
      vpnService = VpnService(storage);
    });

    test('Loads worldwide countries with valid IP addresses', () {
      final servers = vpnService.servers;
      expect(servers.isNotEmpty, isTrue);
      expect(servers.length, greaterThanOrEqualTo(25));

      // Check US, JP, DE, SG, GB presence
      final countryCodes = servers.map((s) => s.countryCode).toSet();
      expect(countryCodes.contains('US'), isTrue);
      expect(countryCodes.contains('JP'), isTrue);
      expect(countryCodes.contains('DE'), isTrue);
      expect(countryCodes.contains('SG'), isTrue);
      expect(countryCodes.contains('GB'), isTrue);

      // Verify each server has valid IP address format
      for (final s in servers) {
        expect(s.ipAddress, matches(RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')));
        expect(s.pingMs, greaterThan(0));
        expect(s.flagEmoji.isNotEmpty, isTrue);
      }
    });

    test('Searches and filters by IP address, country and city', () {
      // Query by IP
      final ipMatch = vpnService.filterServers(query: '198.51.100.42');
      expect(ipMatch.length, 1);
      expect(ipMatch.first.city, 'New York');

      // Query by Country
      final japanServers = vpnService.filterServers(query: 'Japan');
      expect(japanServers.length, greaterThanOrEqualTo(2));

      // Query by Category
      final streaming = vpnService.filterServers(category: ServerCategory.streaming);
      expect(streaming.every((s) => s.category == ServerCategory.streaming), isTrue);
    });

    test('Connects and establishes tunnel with virtual IP', () async {
      expect(vpnService.session.isDisconnected, isTrue);

      await vpnService.connect();
      expect(vpnService.session.isConnected, isTrue);
      expect(vpnService.session.assignedVpnIp, isNotNull);
      expect(vpnService.logs.isNotEmpty, isTrue);

      vpnService.disconnect();
      // Disconnecting state
      expect(vpnService.session.status == VpnStatus.disconnecting || vpnService.session.isDisconnected, isTrue);
    });

    test('Toggles favorite servers and persists in storage', () {
      final serverId = vpnService.servers.first.id;
      expect(vpnService.servers.first.isFavorite, isFalse);

      vpnService.toggleFavorite(serverId);
      expect(vpnService.servers.first.isFavorite, isTrue);
      expect(storage.isFavorite(serverId), isTrue);

      vpnService.toggleFavorite(serverId);
      expect(vpnService.servers.first.isFavorite, isFalse);
    });

    test('Configures Kill Switch, Protocol and DNS', () {
      vpnService.setKillSwitch(false);
      expect(vpnService.session.killSwitchEnabled, isFalse);

      vpnService.setProtocol('OpenVPN UDP');
      expect(vpnService.session.protocol, 'OpenVPN UDP');

      vpnService.setDns('Google DNS (8.8.8.8)');
      expect(vpnService.session.dnsServer, 'Google DNS (8.8.8.8)');
    });
  });
}
