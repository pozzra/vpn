import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyFavorites = 'vpn_favorites';
  static const String _keySelectedServer = 'vpn_selected_server_id';
  static const String _keyProtocol = 'vpn_protocol';
  static const String _keyKillSwitch = 'vpn_kill_switch';
  static const String _keyAutoConnect = 'vpn_auto_connect';
  static const String _keyDns = 'vpn_dns';
  static const String _keySplitTunneling = 'vpn_split_tunneling';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Set<String> getFavoriteIds() {
    final list = _prefs.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  Future<void> toggleFavorite(String serverId) async {
    final favorites = getFavoriteIds();
    if (favorites.contains(serverId)) {
      favorites.remove(serverId);
    } else {
      favorites.add(serverId);
    }
    await _prefs.setStringList(_keyFavorites, favorites.toList());
  }

  bool isFavorite(String serverId) {
    return getFavoriteIds().contains(serverId);
  }

  String? getSelectedServerId() {
    return _prefs.getString(_keySelectedServer);
  }

  Future<void> setSelectedServerId(String id) async {
    await _prefs.setString(_keySelectedServer, id);
  }

  String getProtocol() {
    return _prefs.getString(_keyProtocol) ?? 'WireGuard (Fastest)';
  }

  Future<void> setProtocol(String protocol) async {
    await _prefs.setString(_keyProtocol, protocol);
  }

  bool getKillSwitch() {
    return _prefs.getBool(_keyKillSwitch) ?? true;
  }

  Future<void> setKillSwitch(bool value) async {
    await _prefs.setBool(_keyKillSwitch, value);
  }

  bool getAutoConnect() {
    return _prefs.getBool(_keyAutoConnect) ?? false;
  }

  Future<void> setAutoConnect(bool value) async {
    await _prefs.setBool(_keyAutoConnect, value);
  }

  String getDns() {
    return _prefs.getString(_keyDns) ?? 'Cloudflare (1.1.1.1)';
  }

  Future<void> setDns(String dns) async {
    await _prefs.setString(_keyDns, dns);
  }

  bool getSplitTunneling() {
    return _prefs.getBool(_keySplitTunneling) ?? false;
  }

  Future<void> setSplitTunneling(bool value) async {
    await _prefs.setBool(_keySplitTunneling, value);
  }
}

