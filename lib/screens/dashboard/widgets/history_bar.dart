import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryBar extends StatelessWidget {
  final int value;
  final double max;
  final bool isLast;
  const HistoryBar({
    super.key,
    required this.value,
    required this.max,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / (max == 0 ? 1 : max)).clamp(0, 1.0);
    return Expanded(
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white12,
        ),
        child: Stack(
          children: [
            // Background bar
            Container(
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white12,
              ),
            ),
            // Progress bar
            FractionallySizedBox(
              widthFactor: pct.toDouble(),
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: isLast
                        ? [const Color(0xFFE94560), const Color(0xFFFF6B6B)]
                        : [const Color(0xFF0F3460), const Color(0xFF1A1A2E)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isLast
                                  ? const Color(0xFFE94560)
                                  : const Color(0xFF0F3460))
                              .withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            // Value text
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$value',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
