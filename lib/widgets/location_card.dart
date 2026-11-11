import 'package:flutter/material.dart';
import '../models/vpn_server.dart';
import '../theme/app_theme.dart';

class LocationCard extends StatelessWidget {
  final VpnServer? server;
  final VoidCallback onTapChange;

  const LocationCard({
    super.key,
    required this.server,
    required this.onTapChange,
  });

  @override
  Widget build(BuildContext context) {
    if (server == null) {
      return const SizedBox.shrink();
    }

    final s = server!;

    Color pingColor = AppTheme.accentGreen;
    if (s.pingMs > 80) {
      pingColor = AppTheme.accentRed;
    } else if (s.pingMs > 40) {
      pingColor = AppTheme.accentAmber;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF223048), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTapChange,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Flag Container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E3E5C)),
                  ),
                  child: Center(
                    child: Text(
                      s.flagEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Server info & IP
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              s.countryName,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryCyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.countryCode,
                              style: const TextStyle(
                                color: AppTheme.primaryCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            s.city,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.ipAddress,
                            style: const TextStyle(
                              color: AppTheme.primaryCyan,
                              fontSize: 12,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Ping & Change Action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pingColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.network_ping_rounded, size: 14, color: pingColor),
                          const SizedBox(width: 4),
                          Text(
                            '${s.pingMs} ms',
                            style: TextStyle(
                              color: pingColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Change',
                          style: TextStyle(
                            color: AppTheme.primaryCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.primaryCyan),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

