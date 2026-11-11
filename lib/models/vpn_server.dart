enum ServerCategory {
  all,
  fastest,
  streaming,
  p2p,
  gaming,
  dedicated,
  favorites,
}

class VpnServer {
  final String id;
  final String countryName;
  final String countryCode;
  final String flagEmoji;
  final String region;
  final String city;
  final String ipAddress;
  final int port;
  int pingMs;
  final int loadPercent;
  final ServerCategory category;
  bool isFavorite;
  final List<String> protocols;
  final List<String> features;

  VpnServer({
    required this.id,
    required this.countryName,
    required this.countryCode,
    required this.flagEmoji,
    required this.region,
    required this.city,
    required this.ipAddress,
    this.port = 51820,
    required this.pingMs,
    required this.loadPercent,
    this.category = ServerCategory.all,
    this.isFavorite = false,
    this.protocols = const ['WireGuard', 'OpenVPN UDP', 'OpenVPN TCP', 'IKEv2'],
    this.features = const ['10 Gbps', 'No Logs', 'DNS Leak Shield'],
  });

  String get displayName => '$countryName - $city';

  VpnServer copyWith({
    String? id,
    String? countryName,
    String? countryCode,
    String? flagEmoji,
    String? region,
    String? city,
    String? ipAddress,
    int? port,
    int? pingMs,
    int? loadPercent,
    ServerCategory? category,
    bool? isFavorite,
    List<String>? protocols,
    List<String>? features,
  }) {
    return VpnServer(
      id: id ?? this.id,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      region: region ?? this.region,
      city: city ?? this.city,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      pingMs: pingMs ?? this.pingMs,
      loadPercent: loadPercent ?? this.loadPercent,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      protocols: protocols ?? this.protocols,
      features: features ?? this.features,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryName': countryName,
      'countryCode': countryCode,
      'flagEmoji': flagEmoji,
      'region': region,
      'city': city,
      'ipAddress': ipAddress,
      'port': port,
      'pingMs': pingMs,
      'loadPercent': loadPercent,
      'category': category.name,
      'isFavorite': isFavorite,
      'protocols': protocols,
      'features': features,
    };
  }

  factory VpnServer.fromJson(Map<String, dynamic> json) {
    return VpnServer(
      id: json['id'] as String,
      countryName: json['countryName'] as String,
      countryCode: json['countryCode'] as String,
      flagEmoji: json['flagEmoji'] as String,
      region: json['region'] as String? ?? 'Global',
      city: json['city'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int? ?? 51820,
      pingMs: json['pingMs'] as int? ?? 50,
      loadPercent: json['loadPercent'] as int? ?? 30,
      category: ServerCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ServerCategory.all,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
      protocols: (json['protocols'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['WireGuard', 'OpenVPN UDP'],
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['10 Gbps', 'No Logs'],
    );
  }
}

