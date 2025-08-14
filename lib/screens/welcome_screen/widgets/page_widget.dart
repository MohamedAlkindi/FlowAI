import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildPage({required Map<String, String> page}) {
  return Padding(
    padding: const EdgeInsets.all(40.0),
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            page['icon']!,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 40),
          Text(
            page['title']!,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page['subtitle']!,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[400],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
