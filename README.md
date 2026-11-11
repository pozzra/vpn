# VPN One - High-Speed Secure Flutter VPN

**VPN One** is a high-performance, cybersecurity-grade VPN application built with Flutter. It features a modern cyber-dark UI with glowing holographic state indicators, multi-continent worldwide country server coverage, individual city nodes and dedicated IP addresses, live network throughput graphing, an interactive speed diagnostics suite, IP/DNS leak inspection, and persistent settings.

---

## 🚀 Key Features

### 1. Global Country & Server IP Support
- **Full Continental Coverage**:
  - **Americas**: United States (New York, Los Angeles, Chicago, Miami, Seattle), Canada (Toronto, Vancouver), Mexico (Mexico City), Brazil (São Paulo), Argentina (Buenos Aires), Chile (Santiago).
  - **Europe**: United Kingdom (London, Manchester), Germany (Frankfurt, Berlin), France (Paris), Netherlands (Amsterdam), Switzerland (Zurich), Sweden (Stockholm), Norway (Oslo), Finland (Helsinki), Spain (Madrid), Italy (Milan), Poland (Warsaw), Ireland (Dublin), Austria (Vienna).
  - **Asia-Pacific**: Japan (Tokyo, Osaka), Singapore (Central, Changi), South Korea (Seoul), Hong Kong, Australia (Sydney, Melbourne), India (Mumbai, Delhi), Taiwan (Taipei), Indonesia (Jakarta), Thailand (Bangkok), Malaysia (Kuala Lumpur), Vietnam (Hanoi), Philippines (Manila), New Zealand (Auckland).
  - **Middle East & Africa**: UAE (Dubai), Saudi Arabia (Riyadh), Turkey (Istanbul), Israel (Tel Aviv), South Africa (Johannesburg), Egypt (Cairo).
- **Dedicated IP Display & Filtering**: Search instantly by country, city name, or direct server IP address.
- **Server Specializations**: Dedicated category filters for **Fastest**, **Streaming (Netflix, BBC iPlayer, etc.)**, **Gaming (Anti-DDoS, low jitter)**, **P2P Torrenting**, and **Dedicated IPs**.
- **Favorite Locations**: One-tap bookmarking for instant access.

### 2. Auto-Created Modern UI (Cyber Dark Glassmorphism)
- **Interactive Power Button**: 3D-styled circular power button with dynamic pulsing glow rings, rotating tech borders, and haptic feedback across `DISCONNECTED`, `CONNECTING`, `CONNECTED`, and `DISCONNECTING` states.
- **Live Network Counters**: Real-time Download and Upload speed counters in MB/s, total session data transfer counters, and connection duration timers.
- **Dynamic Throughput Canvas**: Custom smooth wave graph visualizing real-time ingress and egress bandwidth.
- **IP & Security Inspection Modal**: Full audit of active IPv4, ISP, ASN, country/city coordinates, DNS leak test, WebRTC masking, and IPv6 leak protection status.
- **In-App Speed Diagnostics**: Live multi-stage speedometer measuring Ping (latency ms), Jitter (ms), Download speed (Mbps), and Upload speed (Mbps).
- **Tunnel Diagnostics & Logs**: Real-time console viewing cryptographic handshakes, MTU 1420 configuration, and ChaCha20 / AES-256 cipher suite negotiations with one-tap clipboard copy.

### 3. Core Protocols & Privacy Controls
- **Protocols Supported**:
  - `WireGuard (Fastest)` (Lightweight UDP with 10Gbps throughput)
  - `OpenVPN UDP` (Optimized for gaming and streaming)
  - `OpenVPN TCP` (Firewall bypass mode)
  - `IKEv2` (Seamless mobile roaming)
- **Kill Switch Protection**: Blocks all cleartext internet traffic if the tunnel drops.
- **Encrypted DNS Resolvers**: Cloudflare (1.1.1.1), Google DNS (8.8.8.8), and CleanBrowsing AdBlock.
- **Auto-Connect**: Secures untrusted public Wi-Fi networks automatically.
- **Split Tunneling**: Granular bypass support for local LAN and specific applications.

---

## 🛠️ Project Architecture

```
lib/
├── data/
│   └── country_dataset.dart    # 45+ worldwide country servers, cities, pings & IPs
├── models/
│   ├── vpn_server.dart         # Server data model, category enums, JSON serialization
│   └── vpn_session.dart        # Session state machine, metrics, duration, IP records
├── screens/
│   ├── home_screen.dart        # Main dashboard with glowing button, stats, and graph
│   ├── servers_screen.dart     # Global server & IP browser with search and filters
│   ├── ip_details_screen.dart  # Security audit, IP information, and leak detector
│   ├── speed_test_screen.dart  # Live animated speed testing dial
│   ├── settings_screen.dart    # Protocol switch, Kill switch, DNS selection
│   └── logs_screen.dart        # Real-time cryptographic tunnel connection logs
├── services/
│   ├── ip_service.dart         # Public IP & ASN lookups
│   ├── storage_service.dart    # SharedPreferences local persistence
│   └── vpn_service.dart        # State management, traffic tickers, tunnel controller
├── theme/
│   └── app_theme.dart          # Cyberpunk dark theme with neon cyan & emerald green
└── widgets/
    ├── animated_power_button.dart # Glowing multi-ring power switch
    ├── bandwidth_chart.dart       # Live throughput custom painter
    ├── location_card.dart         # Interactive selected server card
    ├── server_tile.dart           # Rich server list item with IP, load & ping
    └── stat_badge.dart            # Ingress/egress metrics tile
```

---

## ⚡ How to Run

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit and widget tests
flutter test

# 3. Launch application (Windows / Chrome / Android / iOS)
flutter run
```
