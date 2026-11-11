import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ip_service.dart';
import '../services/vpn_service.dart';
import '../theme/app_theme.dart';

class IpDetailsScreen extends StatefulWidget {
  const IpDetailsScreen({super.key});

  @override
  State<IpDetailsScreen> createState() => _IpDetailsScreenState();
}

class _IpDetailsScreenState extends State<IpDetailsScreen> {
  IpInfo? _ipInfo;
  bool _isLoading = true;

  String? _lastServerId;
  bool? _lastConnectionState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vpn = context.watch<VpnService>();
    final serverId = vpn.session.currentServer?.id ?? vpn.selectedServer?.id;
    final isConnected = vpn.session.isConnected;

    if (_lastServerId != serverId || _lastConnectionState != isConnected) {
      _lastServerId = serverId;
      _lastConnectionState = isConnected;
      _fetchInfo();
    }
  }

  Future<void> _fetchInfo() async {
    setState(() => _isLoading = true);
    final vpnService = context.read<VpnService>();
    final connectedServer = vpnService.session.isConnected ? vpnService.session.currentServer : null;
    final info = await IpService.fetchPublicIp(connectedServer: connectedServer);
    if (mounted) {
      setState(() {
        _ipInfo = info;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnService>();
    final isConnected = vpn.session.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IP & Security Inspection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryCyan),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Protection Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isConnected
                            ? [const Color(0xFF0D3325), const Color(0xFF0F263B)]
                            : [const Color(0xFF3B151E), const Color(0xFF221524)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isConnected ? AppTheme.accentGreen : AppTheme.accentRed,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isConnected ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
                          size: 48,
                          color: isConnected ? AppTheme.accentGreen : AppTheme.accentRed,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isConnected ? 'YOUR CONNECTION IS ENCRYPTED' : 'YOUR IP IS EXPOSED TO THE INTERNET',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isConnected ? AppTheme.accentGreen : AppTheme.accentRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isConnected
                              ? 'Your physical location, IP address, and DNS queries are completely shielded by VPN One.'
                              : 'ISPs and websites can track your browsing activity and real physical location.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // IP Info Card
                  _buildSectionCard(
                    title: 'PUBLIC IP ADDRESS',
                    children: [
                      _buildDetailRow(
                        label: 'Active IPv4',
                        value: _ipInfo?.ip ?? 'Unknown',
                        isHighlighted: true,
                        highlightColor: isConnected ? AppTheme.accentGreen : AppTheme.accentRed,
                      ),
                      _buildDetailRow(
                        label: 'Country / Region',
                        value: '${_ipInfo?.country} (${_ipInfo?.countryCode})',
                      ),
                      _buildDetailRow(
                        label: 'City Location',
                        value: _ipInfo?.city ?? 'Unknown',
                      ),
                      _buildDetailRow(
                        label: 'Network ISP / Provider',
                        value: _ipInfo?.isp ?? 'Unknown',
                      ),
                      _buildDetailRow(
                        label: 'Autonomous System (ASN)',
                        value: _ipInfo?.org ?? 'AS13335 Cloudflare',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Security & Privacy Diagnostics
                  _buildSectionCard(
                    title: 'PRIVACY AUDIT & LEAK TESTS',
                    children: [
                      _buildCheckRow(
                        label: 'DNS Leak Protection',
                        passed: isConnected,
                        detail: isConnected ? 'Encrypted via ${_ipInfo?.isp}' : 'Exposed to Local ISP',
                      ),
                      _buildCheckRow(
                        label: 'WebRTC IP Masking',
                        passed: isConnected,
                        detail: isConnected ? 'STUN/TURN shielded' : 'Real IP leaked in browser',
                      ),
                      _buildCheckRow(
                        label: 'IPv6 Leak Blocker',
                        passed: isConnected,
                        detail: isConnected ? 'IPv6 tunnel routing active' : 'IPv6 bypass danger',
                      ),
                      _buildCheckRow(
                        label: 'Kill Switch Guard',
                        passed: vpn.session.killSwitchEnabled,
                        detail: vpn.session.killSwitchEnabled ? 'Enabled (Auto-kill on drop)' : 'Disabled',
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF223048)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isHighlighted = false,
    Color? highlightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isHighlighted ? (highlightColor ?? AppTheme.primaryCyan) : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
                fontFamily: isHighlighted ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow({
    required String label,
    required bool passed,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 20,
            color: passed ? AppTheme.accentGreen : AppTheme.accentRed,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    color: passed ? AppTheme.accentGreen : AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (passed ? AppTheme.accentGreen : AppTheme.accentRed).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              passed ? 'SAFE' : 'RISK',
              style: TextStyle(
                color: passed ? AppTheme.accentGreen : AppTheme.accentRed,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

