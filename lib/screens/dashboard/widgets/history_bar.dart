import 'package:flutter/material.dart';

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
    // Bar height: constant
    const barHeight = 24.0;
    // Color interpolation: blue (low) to red (high)
    Color lerpColor(Color a, Color b, double t) => Color.lerp(a, b, t)!;
    final barColor = lerpColor(
      const Color(0xFF0F3460),
      const Color(0xFFE94560),
      pct.toDouble(),
    );
    // Text color: white if bar is dark, black if bar is light
    bool isDark(Color c) => c.computeLuminance() < 0.5;
    final textColor = isDark(barColor) ? Colors.white : Colors.black;
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final barWidth = (maxWidth * pct).clamp(
            0.0,
            maxWidth,
          ); // min width is 0 for true proportionality
          return Stack(
            children: [
              // Background bar (neutral, full width)
              Container(
                height: barHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white12,
                ),
              ),
              // Progress bar (width varies, colored)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: barColor,
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withOpacity(0.3),
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
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
