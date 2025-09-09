import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RowValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const RowValue({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 8),

            Text(
              label,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
