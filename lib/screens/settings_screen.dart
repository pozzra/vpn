import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vpn_service.dart';
import '../theme/app_theme.dart';
import 'logs_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnService>();
    final session = vpn.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSectionHeader('CORE SECURITY PROTOCOLS'),
          _buildProtocolSelector(context, vpn),
          const SizedBox(height: 24),

          _buildSectionHeader('PRIVACY & LEAK PROTECTION'),
          _buildSettingCard([
            _buildSwitchTile(
              title: 'Kill Switch',
              subtitle: 'Cut internet access automatically if VPN connection drops.',
              icon: Icons.shield_rounded,
              iconColor: AppTheme.accentGreen,
              value: session.killSwitchEnabled,
              onChanged: (val) => vpn.setKillSwitch(val),
            ),
            const Divider(color: AppTheme.dividerColor, height: 1),
            _buildSwitchTile(
              title: 'Auto-Connect',
              subtitle: 'Automatically connect on untrusted public Wi-Fi networks.',
              icon: Icons.wifi_protected_setup_rounded,
              iconColor: AppTheme.primaryCyan,
              value: session.autoConnectEnabled,
              onChanged: (val) => vpn.setAutoConnect(val),
            ),
            const Divider(color: AppTheme.dividerColor, height: 1),
            _buildSwitchTile(
              title: 'Split Tunneling',
              subtitle: 'Allow selected apps to bypass VPN encryption.',
              icon: Icons.call_split_rounded,
              iconColor: AppTheme.accentPurple,
              value: session.splitTunnelingEnabled,
              onChanged: (val) => vpn.setSplitTunneling(val),
            ),
          ]),
          const SizedBox(height: 24),

          _buildSectionHeader('ENCRYPTED DNS RESOLVER'),
          _buildDnsSelector(context, vpn),
          const SizedBox(height: 24),

          _buildSectionHeader('SYSTEM & DIAGNOSTICS'),
          _buildSettingCard([
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.terminal_rounded, color: AppTheme.primaryBlue),
              ),
              title: const Text(
                'Tunnel Diagnostic Logs',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'View live cryptographic handshakes, MTU & routing tables',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LogsScreen()),
                );
              },
            ),
          ]),
          const SizedBox(height: 32),

          // About app
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lock_rounded, size: 16, color: AppTheme.primaryCyan),
                    SizedBox(width: 6),
                    Text(
                      'VPN ONE',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Next-Gen High-Speed WireGuard VPN • v2.4.0',
                  style: TextStyle(color: AppTheme.textTertiary, fontSize: 11),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Material(
      color: AppTheme.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF223048)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.primaryCyan,
            activeTrackColor: AppTheme.primaryCyan.withValues(alpha: 0.3),
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.surfaceElevated,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolSelector(BuildContext context, VpnService vpn) {
    final protocols = [
      {'name': 'WireGuard (Fastest)', 'desc': 'Modern lightweight protocol with 10Gbps throughput'},
      {'name': 'OpenVPN UDP', 'desc': 'Standard balanced protocol for gaming & streaming'},
      {'name': 'OpenVPN TCP', 'desc': 'Maximum reliability, bypasses restrictive firewalls'},
      {'name': 'IKEv2', 'desc': 'Fast reconnect for mobile & changing networks'},
    ];

    return Material(
      color: AppTheme.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF223048)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: protocols.map((proto) {
          final isSelected = vpn.session.protocol == proto['name'];
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                title: Text(
                  proto['name']!,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryCyan : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  proto['desc']!,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryCyan)
                    : const Icon(Icons.circle_outlined, color: AppTheme.textTertiary),
                onTap: () => vpn.setProtocol(proto['name']!),
              ),
              if (proto != protocols.last)
                const Divider(color: AppTheme.dividerColor, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDnsSelector(BuildContext context, VpnService vpn) {
    final dnsOptions = [
      {'name': 'Cloudflare (1.1.1.1)', 'desc': 'Fastest DNS with privacy-first logging'},
      {'name': 'Google DNS (8.8.8.8)', 'desc': 'Global geo-redundant query resolution'},
      {'name': 'CleanBrowsing AdBlock', 'desc': 'Blocks malware, phishing & trackers at DNS level'},
    ];

    return Material(
      color: AppTheme.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFF223048)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: dnsOptions.map((opt) {
          final isSelected = vpn.session.dnsServer == opt['name'];
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                title: Text(
                  opt['name']!,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryCyan : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  opt['desc']!,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryCyan)
                    : const Icon(Icons.circle_outlined, color: AppTheme.textTertiary),
                onTap: () => vpn.setDns(opt['name']!),
              ),
              if (opt != dnsOptions.last)
                const Divider(color: AppTheme.dividerColor, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

