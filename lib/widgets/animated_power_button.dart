import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/vpn_session.dart';
import '../theme/app_theme.dart';

class AnimatedPowerButton extends StatefulWidget {
  final VpnStatus status;
  final VoidCallback onTap;

  const AnimatedPowerButton({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<AnimatedPowerButton> createState() => _AnimatedPowerButtonState();
}

class _AnimatedPowerButtonState extends State<AnimatedPowerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color glowColor;
    Color buttonGradientStart;
    Color buttonGradientEnd;
    IconData icon;
    String statusText;

    switch (widget.status) {
      case VpnStatus.connected:
        glowColor = AppTheme.accentGreen;
        buttonGradientStart = const Color(0xFF00E676);
        buttonGradientEnd = const Color(0xFF00B0FF);
        icon = Icons.lock_rounded;
        statusText = 'CONNECTED';
        break;
      case VpnStatus.connecting:
        glowColor = AppTheme.accentAmber;
        buttonGradientStart = const Color(0xFFFFB300);
        buttonGradientEnd = const Color(0xFFFF6D00);
        icon = Icons.sync_rounded;
        statusText = 'CONNECTING...';
        break;
      case VpnStatus.disconnecting:
        glowColor = AppTheme.accentRed;
        buttonGradientStart = const Color(0xFFFF5252);
        buttonGradientEnd = const Color(0xFFFF1744);
        icon = Icons.lock_open_rounded;
        statusText = 'DISCONNECTING';
        break;
      case VpnStatus.disconnected:
        glowColor = AppTheme.primaryCyan;
        buttonGradientStart = const Color(0xFF1E2B45);
        buttonGradientEnd = const Color(0xFF121929);
        icon = Icons.power_settings_new_rounded;
        statusText = 'TAP TO CONNECT';
        break;
    }

    final isConnecting = widget.status == VpnStatus.connecting;
    final isConnected = widget.status == VpnStatus.connected;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = isConnected || isConnecting ? _pulseAnimation.value : 1.0;

              return Transform.scale(
                scale: scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ambient pulsing glow
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isConnected || isConnecting)
                                ? glowColor.withValues(alpha: 0.35)
                                : glowColor.withValues(alpha: 0.12),
                            blurRadius: isConnected ? 45 : 25,
                            spreadRadius: isConnected ? 8 : 2,
                          ),
                        ],
                      ),
                    ),

                    // Rotating dashed tech ring
                    Transform.rotate(
                      angle: isConnecting ? _rotationAnimation.value : 0,
                      child: Container(
                        width: 175,
                        height: 175,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: glowColor.withValues(alpha: isConnected ? 0.6 : 0.25),
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                      ),
                    ),

                    // Inner main button circle
                    Container(
                      width: 145,
                      height: 145,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [buttonGradientStart, buttonGradientEnd],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isConnecting
                            ? const SizedBox(
                                width: 52,
                                height: 52,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 4,
                                ),
                              )
                            : Icon(
                                icon,
                                size: 56,
                                color: isConnected ? Colors.black87 : Colors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(statusText),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: glowColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: glowColor.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glowColor,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: glowColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

