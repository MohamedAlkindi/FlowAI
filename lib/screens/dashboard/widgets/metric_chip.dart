import 'package:flutter/material.dart';


class MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final Color bg;

  const MetricChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              color: Colors.white
            ),
          ),
        ],
      ),
    );
  }
}
