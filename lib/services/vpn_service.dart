import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/country_dataset.dart';
import '../models/vpn_server.dart';
import '../models/vpn_session.dart';
import 'storage_service.dart';

class TrafficPoint {
  final double downloadKbps;
  final double uploadKbps;
  final DateTime time;

  TrafficPoint(this.downloadKbps, this.uploadKbps, this.time);
}

class VpnService extends ChangeNotifier {
  final StorageService _storage;
  List<VpnServer> _servers = [];
  VpnServer? _selectedServer;
  VpnSessionState _session = const VpnSessionState();

  final List<String> _logs = [];
  final List<TrafficPoint> _trafficHistory = [];
  Timer? _tickerTimer;
  final Random _random = Random();

  VpnService(this._storage) {
    _init();
  }

  List<VpnServer> get servers => _servers;
  VpnServer? get selectedServer => _selectedServer;
  VpnSessionState get session => _session;
  List<String> get logs => List.unmodifiable(_logs);
  List<TrafficPoint> get trafficHistory => List.unmodifiable(_trafficHistory);

  void _init() {
    final favorites = _storage.getFavoriteIds();
    _servers = CountryDataset.getServers().map((s) {
      if (favorites.contains(s.id)) {
        s.isFavorite = true;
      }
      return s;
    }).toList();

    final savedId = _storage.getSelectedServerId();
    if (savedId != null) {
      _selectedServer = _servers.firstWhere(
        (s) => s.id == savedId,
        orElse: () => _servers.first,
      );
    } else {
      _selectedServer = _servers.first;
    }

    _session = _session.copyWith(
      protocol: _storage.getProtocol(),
      killSwitchEnabled: _storage.getKillSwitch(),
      autoConnectEnabled: _storage.getAutoConnect(),
      dnsServer: _storage.getDns(),
      splitTunnelingEnabled: _storage.getSplitTunneling(),
    );

    _addLog('VPN One Service initialized. Ready for connections.');

    // Pre-populate empty traffic points
    for (int i = 0; i < 15; i++) {
      _trafficHistory.add(TrafficPoint(0, 0, DateTime.now().subtract(Duration(seconds: 15 - i))));
    }

    // Auto connect if enabled
    if (_session.autoConnectEnabled) {
      connect();
    }
  }

  void _addLog(String message) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _logs.insert(0, '[$timeStr] $message');
    if (_logs.length > 200) {
      _logs.removeLast();
    }
  }

  void selectServer(VpnServer server) {
    if (_session.status == VpnStatus.connecting) return;
    _selectedServer = server;
    _storage.setSelectedServerId(server.id);
    _addLog('Selected server: ${server.countryName} - ${server.city} (${server.ipAddress})');

    if (_session.isConnected) {
      // Reconnect to new server
      disconnect();
      Future.delayed(const Duration(milliseconds: 600), () {
        connect();
      });
    } else {
      notifyListeners();
    }
  }

  void toggleFavorite(String serverId) {
    _storage.toggleFavorite(serverId);
    final index = _servers.indexWhere((s) => s.id == serverId);
    if (index != -1) {
      _servers[index].isFavorite = !_servers[index].isFavorite;
      notifyListeners();
    }
  }

  VpnServer getFastestServer() {
    return _servers.reduce((curr, next) => curr.pingMs < next.pingMs ? curr : next);
  }

  void selectFastest() {
    selectServer(getFastestServer());
  }

  Future<void> connect() async {
    if (_session.isConnected || _session.isConnecting) return;
    if (_selectedServer == null && _servers.isNotEmpty) {
      _selectedServer = _servers.first;
    }
    final server = _selectedServer!;

    _session = _session.copyWith(
      status: VpnStatus.connecting,
      currentServer: server,
    );
    notifyListeners();

    _addLog('Connecting to ${server.countryName} [${server.city}]...');
    _addLog('Target Server IP: ${server.ipAddress}:${server.port}');
    _addLog('Protocol: ${_session.protocol} | DNS: ${_session.dnsServer}');
    _addLog('Negotiating ChaCha20-Poly1305 / AES-256-GCM cipher suite...');

    await Future.delayed(const Duration(milliseconds: 700));
    _addLog('WireGuard interface wg0 up. Setting MTU 1420...');
    await Future.delayed(const Duration(milliseconds: 700));

    final assignedIp = '${server.ipAddress.split('.').take(3).join('.')}.${_random.nextInt(150) + 10}';
    _addLog('Tunnel established! Assigned Virtual IP: $assignedIp');
    _addLog('Routing 0.0.0.0/0 -> wg0 (DNS Leak Shield Active)');

    _session = _session.copyWith(
      status: VpnStatus.connected,
      assignedVpnIp: assignedIp,
      duration: Duration.zero,
      bytesIn: 0,
      bytesOut: 0,
    );
    notifyListeners();

    _startBandwidthTicker();
  }

  void disconnect() {
    if (_session.isDisconnected || _session.status == VpnStatus.disconnecting) return;

    _tickerTimer?.cancel();
    _session = _session.copyWith(status: VpnStatus.disconnecting);
    notifyListeners();

    _addLog('Disconnecting VPN tunnel...');
    _addLog('Restoring default routing table & DNS...');

    Future.delayed(const Duration(milliseconds: 600), () {
      _session = _session.copyWith(
        status: VpnStatus.disconnected,
        assignedVpnIp: null,
        downloadSpeedKbps: 0.0,
        uploadSpeedKbps: 0.0,
      );
      _addLog('Disconnected safely. Internet connection restored.');
      notifyListeners();
    });
  }

  void toggleConnect() {
    if (_session.isConnected) {
      disconnect();
    } else if (_session.isDisconnected) {
      connect();
    }
  }

  void _startBandwidthTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_session.isConnected) {
        timer.cancel();
        return;
      }

      // Generate realistic fluctuating speeds (e.g. 5,000 - 85,000 KB/s = 5 - 85 MB/s)
      final baseDown = 15000 + _random.nextInt(35000);
      final spikeDown = _random.nextDouble() > 0.8 ? _random.nextInt(25000) : 0;
      final downSpeed = (baseDown + spikeDown).toDouble();

      final baseUp = 4000 + _random.nextInt(12000);
      final upSpeed = baseUp.toDouble();

      final newBytesIn = _session.bytesIn + (downSpeed * 1024).toInt();
      final newBytesOut = _session.bytesOut + (upSpeed * 1024).toInt();
      final newDuration = _session.duration + const Duration(seconds: 1);

      // Fluctuating ping
      if (_selectedServer != null) {
        final jitter = _random.nextInt(5) - 2;
        _selectedServer!.pingMs = max(5, _selectedServer!.pingMs + jitter);
      }

      _trafficHistory.add(TrafficPoint(downSpeed / 1024, upSpeed / 1024, DateTime.now()));
      if (_trafficHistory.length > 20) {
        _trafficHistory.removeAt(0);
      }

      _session = _session.copyWith(
        duration: newDuration,
        bytesIn: newBytesIn,
        bytesOut: newBytesOut,
        downloadSpeedKbps: downSpeed,
        uploadSpeedKbps: upSpeed,
      );
      notifyListeners();
    });
  }

  void setProtocol(String protocol) {
    _session = _session.copyWith(protocol: protocol);
    _storage.setProtocol(protocol);
    _addLog('Protocol updated to $protocol');
    notifyListeners();
  }

  void setKillSwitch(bool value) {
    _session = _session.copyWith(killSwitchEnabled: value);
    _storage.setKillSwitch(value);
    _addLog('Kill Switch ${value ? "enabled (Traffic blocked if VPN disconnects)" : "disabled"}');
    notifyListeners();
  }

  void setAutoConnect(bool value) {
    _session = _session.copyWith(autoConnectEnabled: value);
    _storage.setAutoConnect(value);
    _addLog('Auto-Connect ${value ? "enabled" : "disabled"}');
    notifyListeners();
  }

  void setDns(String dns) {
    _session = _session.copyWith(dnsServer: dns);
    _storage.setDns(dns);
    _addLog('DNS provider changed to $dns');
    notifyListeners();
  }

  void setSplitTunneling(bool value) {
    _session = _session.copyWith(splitTunnelingEnabled: value);
    _storage.setSplitTunneling(value);
    _addLog('Split Tunneling ${value ? "enabled" : "disabled"}');
    notifyListeners();
  }

  List<VpnServer> filterServers({
    String query = '',
    ServerCategory category = ServerCategory.all,
    String region = 'All',
  }) {
    return _servers.where((server) {
      // Region filter
      if (region != 'All' && server.region != region) {
        return false;
      }

      // Category filter
      if (category == ServerCategory.favorites) {
        if (!server.isFavorite) return false;
      } else if (category != ServerCategory.all) {
        if (server.category != category) return false;
      }

      // Search query (Country, City, IP address)
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchCountry = server.countryName.toLowerCase().contains(q);
        final matchCity = server.city.toLowerCase().contains(q);
        final matchIp = server.ipAddress.contains(q);
        final matchCode = server.countryCode.toLowerCase().contains(q);
        if (!matchCountry && !matchCity && !matchIp && !matchCode) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}

