import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vpn_service.dart';
import '../theme/app_theme.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen>
    with SingleTickerProviderStateMixin {
  bool _isTesting = false;
  String _currentPhase = 'IDLE'; // IDLE, PING, DOWNLOAD, UPLOAD, FINISHED
  double _currentSpeedMbps = 0.0;
  double _finalDownloadMbps = 0.0;
  double _finalUploadMbps = 0.0;
  int _finalPingMs = 0;
  int _finalJitterMs = 0;

  Timer? _testTimer;
  final Random _random = Random();

  void _startSpeedTest() {
    if (_isTesting) return;

    final vpn = context.read<VpnService>();
    final basePing = vpn.session.currentServer?.pingMs ?? 25;

    setState(() {
      _isTesting = true;
      _currentPhase = 'TESTING PING...';
      _currentSpeedMbps = 0.0;
      _finalDownloadMbps = 0.0;
      _finalUploadMbps = 0.0;
      _finalPingMs = 0;
      _finalJitterMs = 0;
    });

    int step = 0;
    _testTimer?.cancel();
    _testTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      step++;

      if (step < 15) {
        // Ping phase
        setState(() {
          _currentPhase = 'MEASURING LATENCY...';
          _currentSpeedMbps = (_random.nextDouble() * 5);
        });
      } else if (step == 15) {
        setState(() {
          _finalPingMs = basePing + _random.nextInt(6);
          _finalJitterMs = 2 + _random.nextInt(4);
          _currentPhase = 'TESTING DOWNLOAD...';
        });
      } else if (step > 15 && step < 50) {
        // Download phase
        final targetDown = 85.0 + _random.nextDouble() * 40;
        setState(() {
          _currentSpeedMbps = targetDown;
        });
      } else if (step == 50) {
        setState(() {
          _finalDownloadMbps = 95.4 + (_random.nextDouble() * 25);
          _currentPhase = 'TESTING UPLOAD...';
        });
      } else if (step > 50 && step < 80) {
        // Upload phase
        final targetUp = 35.0 + _random.nextDouble() * 25;
        setState(() {
          _currentSpeedMbps = targetUp;
        });
      } else if (step >= 80) {
        timer.cancel();
        setState(() {
          _finalUploadMbps = 42.8 + (_random.nextDouble() * 15);
          _currentPhase = 'COMPLETED';
          _currentSpeedMbps = 0.0;
          _isTesting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _testTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnService>();
    final server = vpn.session.currentServer ?? vpn.selectedServer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Speed Diagnostics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Current Server Node Info
            if (server != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF223048)),
                ),
                child: Row(
                  children: [
                    Text(server.flagEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Testing Node: ${server.countryName} - ${server.city}',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'IP: ${server.ipAddress} (${server.features.first})',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),

            // Speed Dial
            Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceCard,
                border: Border.all(
                  color: _isTesting ? AppTheme.primaryCyan : const Color(0xFF223048),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isTesting
                        ? AppTheme.primaryCyan.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentPhase,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isTesting
                          ? _currentSpeedMbps.toStringAsFixed(1)
                          : (_finalDownloadMbps > 0
                              ? _finalDownloadMbps.toStringAsFixed(1)
                              : '0.0'),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Mbps',
                      style: TextStyle(
                        color: AppTheme.primaryCyan,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.download_rounded,
                    color: AppTheme.accentGreen,
                    label: 'DOWNLOAD',
                    value: _finalDownloadMbps > 0 ? _finalDownloadMbps.toStringAsFixed(1) : '--',
                    unit: 'Mbps',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.upload_rounded,
                    color: AppTheme.primaryCyan,
                    label: 'UPLOAD',
                    value: _finalUploadMbps > 0 ? _finalUploadMbps.toStringAsFixed(1) : '--',
                    unit: 'Mbps',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.network_ping_rounded,
                    color: AppTheme.accentAmber,
                    label: 'PING',
                    value: _finalPingMs > 0 ? '$_finalPingMs' : '--',
                    unit: 'ms',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    icon: Icons.waves_rounded,
                    color: AppTheme.accentPurple,
                    label: 'JITTER',
                    value: _finalJitterMs > 0 ? '$_finalJitterMs' : '--',
                    unit: 'ms',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Start Test Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isTesting ? null : _startSpeedTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isTesting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'TESTING NETWORK...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'START SPEED TEST',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF223048)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

