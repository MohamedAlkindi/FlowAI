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
      print('DashboardService: Received JSON string: $jsonString');
      if (jsonString == null || jsonString.isEmpty) {
        print('DashboardService: JSON string is null or empty');
        return null;
      }
      final Map<String, dynamic> json = jsonDecode(jsonString);
      print('DashboardService: Parsed JSON: $json');
      final usage = DashboardUsage.fromJson(json);
      print('DashboardService: Created DashboardUsage: $usage');
      return usage;
    } catch (e) {
      print('DashboardService: Error getting saved usage: $e');
      return null;
    }
  }

  static Future<void> testSaveUsage() async {
    try {
      await _channel.invokeMethod('testSaveUsage');
      print('DashboardService: Test usage data saved');
    } catch (e) {
      print('DashboardService: Error saving test usage: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUsageHistory() async {
    try {
      final jsonString = await _channel.invokeMethod<String>('getDashboardUsageHistory');
      if (jsonString == null || jsonString.isEmpty) return const [];
      final List<dynamic> arr = jsonDecode(jsonString);
      return arr
          .whereType<Map<String, dynamic>>()
          .map((e) => e)
          .toList();
    } catch (e) {
      print('DashboardService: Error getting usage history: $e');
      return const [];
    }
  }
}
