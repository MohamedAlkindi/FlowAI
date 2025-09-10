import 'dart:convert';

import 'package:flow_ai/models/dashboard_usage.dart';
import 'package:flutter/services.dart';

class DashboardService {
  static const MethodChannel _channel = MethodChannel('flow_ai/platform');

  static Future<DashboardUsage?> getSavedUsage() async {
    try {
      final jsonString = await _channel.invokeMethod<String>(
        'getDashboardUsage',
      );
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final usage = DashboardUsage.fromJson(json);
      return usage;
    } catch (e) {
      return null;
    }
  }

  static Future<void> testSaveUsage() async {
    try {
      await _channel.invokeMethod('testSaveUsage');
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getUsageHistory() async {
    try {
      final jsonString = await _channel.invokeMethod<String>(
        'getDashboardUsageHistory',
      );
      if (jsonString == null || jsonString.isEmpty) return const [];
      final List<dynamic> arr = jsonDecode(jsonString);
      return arr.whereType<Map<String, dynamic>>().map((e) => e).toList();
    } catch (e) {
      return const [];
    }
  }
}
