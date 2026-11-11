import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vpn_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_power_button.dart';
import '../widgets/bandwidth_chart.dart';
import '../widgets/location_card.dart';
import '../widgets/stat_badge.dart';
import 'ip_details_screen.dart';
import 'servers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _formatData(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnService>();
    final session = vpn.session;
    final isConnected = session.isConnected;
    final isConnecting = session.isConnecting;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: AppTheme.primaryCyan,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'VPN ONE',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Secure WireGuard Tunnel',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // IP / Security Audit Button
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IpDetailsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? AppTheme.accentGreen.withValues(alpha: 0.15)
                            : AppTheme.accentRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isConnected
                              ? AppTheme.accentGreen.withValues(alpha: 0.4)
                              : AppTheme.accentRed.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isConnected ? Icons.lock_rounded : Icons.lock_open_rounded,
                            size: 14,
                            color: isConnected ? AppTheme.accentGreen : AppTheme.accentRed,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected ? 'IP SHIELDED' : 'IP EXPOSED',
                            style: TextStyle(
                              color: isConnected ? AppTheme.accentGreen : AppTheme.accentRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Status Subtitle & Duration Timer
              if (isConnected) ...[
                Text(
                  _formatDuration(session.duration),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.vpn_key_rounded, size: 13, color: AppTheme.accentGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Assigned IP: ${session.assignedVpnIp ?? "Configuring..."}',
                      style: const TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ] else if (isConnecting) ...[
                const Text(
                  'NEGOTIATING ENCRYPTION...',
                  style: TextStyle(
                    color: AppTheme.accentAmber,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Exchanging Curve25519 Keys',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ] else ...[
                const Text(
                  'UNPROTECTED CONNECTION',
                  style: TextStyle(
                    color: AppTheme.accentRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real IP: ${session.originalPublicIp} (ISP Trackable)',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
              const SizedBox(height: 28),

              // Animated Connect Power Button
              AnimatedPowerButton(
                status: session.status,
                onTap: () => vpn.toggleConnect(),
              ),
              const SizedBox(height: 32),

              // Location Selector Card
              LocationCard(
                server: session.currentServer ?? vpn.selectedServer,
                onTapChange: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ServersScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Live Stats Grid
              Row(
                children: [
                  Expanded(
                    child: StatBadge(
                      icon: Icons.download_rounded,
                      iconColor: AppTheme.accentGreen,
                      label: 'DOWNLOAD',
                      value: isConnected
                          ? (session.downloadSpeedKbps / 1024).toStringAsFixed(1)
                          : '0.0',
                      unit: 'MB/s',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatBadge(
                      icon: Icons.upload_rounded,
                      iconColor: AppTheme.primaryCyan,
                      label: 'UPLOAD',
                      value: isConnected
                          ? (session.uploadSpeedKbps / 1024).toStringAsFixed(1)
                          : '0.0',
                      unit: 'MB/s',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatBadge(
                      icon: Icons.data_usage_rounded,
                      iconColor: AppTheme.accentPurple,
                      label: 'DATA USED',
                      value: isConnected
                          ? _formatData(session.bytesIn + session.bytesOut)
                          : '0.0 MB',
                      unit: '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatBadge(
                      icon: Icons.network_ping_rounded,
                      iconColor: AppTheme.accentAmber,
                      label: 'PING',
                      value: (session.currentServer ?? vpn.selectedServer)?.pingMs.toString() ?? '--',
                      unit: 'ms',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Live Bandwidth Graph
              if (isConnected) ...[
                BandwidthChart(history: vpn.trafficHistory),
                const SizedBox(height: 20),
              ],

              // Quick Connect to Fastest Button
              if (!isConnected)
                Container(
                  width: double.infinity,
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.bolt_rounded, color: AppTheme.primaryCyan),
                    label: const Text(
                      'CONNECT TO FASTEST SERVER',
                      style: TextStyle(
                        color: AppTheme.primaryCyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryCyan, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      vpn.selectFastest();
                      vpn.connect();
                    },
                  ),
                ),

              // Protocol & Security Details Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF223048)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureItem(Icons.security_rounded, session.protocol.split(' ').first),
                    _buildDivider(),
                    _buildFeatureItem(Icons.dns_rounded, session.dnsServer.split(' ').first),
                    _buildDivider(),
                    _buildFeatureItem(
                      Icons.shield_rounded,
                      session.killSwitchEnabled ? 'Kill Switch ON' : 'Kill Switch OFF',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryCyan),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 14,
      color: const Color(0xFF2C3C58),
    );
  }
}

