import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/vpn_service.dart';
import '../theme/app_theme.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnService>();
    final logs = vpn.logs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tunnel Diagnostics & Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy Logs',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: logs.join('\n')));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('VPN Logs copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text(
                'No connection logs yet.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final line = logs[index];
                Color lineColor = AppTheme.textSecondary;
                if (line.contains('established') || line.contains('SUCCESS')) {
                  lineColor = AppTheme.accentGreen;
                } else if (line.contains('Connecting') || line.contains('Negotiating')) {
                  lineColor = AppTheme.accentAmber;
                } else if (line.contains('Disconnected') || line.contains('ERROR')) {
                  lineColor = AppTheme.accentRed;
                } else if (line.contains('Selected')) {
                  lineColor = AppTheme.primaryCyan;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    line,
                    style: TextStyle(
                      color: lineColor,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

