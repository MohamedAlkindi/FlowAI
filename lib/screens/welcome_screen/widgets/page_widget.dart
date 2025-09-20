import 'package:flutter/material.dart';


Widget buildPage({required Map<String, String> page}) {
  return Padding(
    padding: const EdgeInsets.all(40.0),
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page['custom'] == 'language') ...[
            // Language selection page handled externally
            const SizedBox.shrink(),
          ] else ...[
            Text(page['icon']!, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 40),
            Text(
              page['title']!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              page['subtitle']!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}
