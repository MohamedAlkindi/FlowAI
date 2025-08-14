import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildResultCard({required String text}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF0F3460),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: GoogleFonts.poppins(color: Colors.white),
    ),
  );
}
