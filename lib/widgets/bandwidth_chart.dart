import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/vpn_service.dart';
import '../theme/app_theme.dart';

class BandwidthChart extends StatelessWidget {
  final List<TrafficPoint> history;

  const BandwidthChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF223048)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE THROUGHPUT',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                children: [
                  _buildLegend(AppTheme.accentGreen, 'DL'),
                  const SizedBox(width: 12),
                  _buildLegend(AppTheme.primaryCyan, 'UL'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrafficChartPainter(history),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TrafficChartPainter extends CustomPainter {
  final List<TrafficPoint> history;

  _TrafficChartPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    double maxSpeed = 10.0;
    for (final point in history) {
      maxSpeed = math.max(maxSpeed, math.max(point.downloadKbps, point.uploadKbps));
    }

    final downloadPath = Path();
    final uploadPath = Path();

    final dx = size.width / (history.length - 1);

    for (int i = 0; i < history.length; i++) {
      final point = history[i];
      final x = i * dx;
      final yDown = size.height - (point.downloadKbps / maxSpeed * (size.height - 10));
      final yUp = size.height - (point.uploadKbps / maxSpeed * (size.height - 10));

      if (i == 0) {
        downloadPath.moveTo(x, yDown);
        uploadPath.moveTo(x, yUp);
      } else {
        downloadPath.lineTo(x, yDown);
        uploadPath.lineTo(x, yUp);
      }
    }

    // Grid baseline
    final gridPaint = Paint()
      ..color = const Color(0xFF223048)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);

    // Download Paint
    final dlPaint = Paint()
      ..color = AppTheme.accentGreen
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Upload Paint
    final ulPaint = Paint()
      ..color = AppTheme.primaryCyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(downloadPath, dlPaint);
    canvas.drawPath(uploadPath, ulPaint);
  }

  @override
  bool shouldRepaint(covariant _TrafficChartPainter oldDelegate) => true;
}

