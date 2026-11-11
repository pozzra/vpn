import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vpn_server.dart';
import '../services/config_service.dart';
import '../theme/app_theme.dart';

class ServerTile extends StatelessWidget {
  final VpnServer server;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ServerTile({
    super.key,
    required this.server,
    required this.isSelected,
    required this.onTap,
    required this.onToggleFavorite,
  });

  void _showConfigSheet(BuildContext context) {
    final wgConfig = ConfigService.generateWireGuardConfig(server: server);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(server.flagEmoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Text(
                        '${server.countryName} - ${server.city}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Server IP: ${server.ipAddress}:${server.port} • ${server.pingMs}ms',
                style: const TextStyle(
                  color: AppTheme.primaryCyan,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'WIREGUARD CLIENT CONFIG (.conf)',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2B3A55)),
                ),
                child: Text(
                  wgConfig,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('COPY WIREGUARD CONFIG', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: wgConfig));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('WireGuard config for ${server.city} copied to clipboard'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color pingColor = AppTheme.accentGreen;
    if (server.pingMs > 80) {
      pingColor = AppTheme.accentRed;
    } else if (server.pingMs > 40) {
      pingColor = AppTheme.accentAmber;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.surfaceElevated : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryCyan : const Color(0xFF223048),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: () => _showConfigSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Flag
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF283854)),
                  ),
                  child: Center(
                    child: Text(
                      server.flagEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Country, City & IP
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              server.countryName,
                              style: TextStyle(
                                color: isSelected ? AppTheme.primaryCyan : AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '- ${server.city}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // IP badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101724),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF202E46)),
                            ),
                            child: Text(
                              server.ipAddress,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Server Load
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                size: 14,
                                color: server.loadPercent > 70
                                    ? AppTheme.accentRed
                                    : AppTheme.textTertiary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${server.loadPercent}%',
                                style: TextStyle(
                                  color: server.loadPercent > 70
                                      ? AppTheme.accentRed
                                      : AppTheme.textTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Ping & Favorite & Config
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ping pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pingColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${server.pingMs}ms',
                        style: TextStyle(
                          color: pingColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Config info button
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      tooltip: 'WireGuard Config',
                      onPressed: () => _showConfigSheet(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 6),

                    // Favorite button
                    IconButton(
                      icon: Icon(
                        server.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                        color: server.isFavorite ? AppTheme.accentAmber : AppTheme.textTertiary,
                        size: 22,
                      ),
                      onPressed: onToggleFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
