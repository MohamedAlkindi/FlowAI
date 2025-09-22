import 'package:flutter/material.dart';

Widget cardTitleRow({required IconData icon, required String cardTitle}) {
  return Row(
    children: [
      Icon(icon, size: 40, color: Color(0xFFE94560)),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          cardTitle,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
          softWrap: true,
        ),
      ),
    ],
  );
}
