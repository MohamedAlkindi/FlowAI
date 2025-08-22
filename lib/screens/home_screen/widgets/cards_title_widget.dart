import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget cardTitleRow({required IconData icon, required String cardTitle}) {
  return Row(
    children: [
      Icon(
        icon,
        size: 40,
        color: Color(0xFFE94560),
      ),
      const SizedBox(width: 12),
      Text(
        cardTitle,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        softWrap: true,
      ),
    ],
  );
}
