import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as dev;

class SupabaseFunctionService {
  static Future<String> invokeGenerate(
      {required String prompt, required String deviceId}) async {
    final client = Supabase.instance.client;
    try {
      final response = await client.functions.invoke(
        'gemini',
        body: {
          'prompt': prompt,
          'deviceId': deviceId,
        },
      );

      final status = response.status;
      final bodyData = response.data;
      final bodyStr = bodyData is String ? bodyData : jsonEncode(bodyData);

      if (status == 200 || status == 201) {
        try {
          final data = bodyData is String ? jsonDecode(bodyData) : bodyData;
          if (data is Map && data['text'] is String) {
            return data['text'] as String;
          }
        } catch (_) {}
        return bodyStr;
      }

      // Error path: try to extract a meaningful message from JSON or plain text
      String extractMessageFromError(dynamic errorJson) {
        if (errorJson is Map) {
          // Direct message field
          final directMessage = errorJson['message'];

          dev.log(directMessage);
          if (directMessage is String && directMessage.trim().isNotEmpty) {
            return directMessage.trim();
          }

          // Supabase or upstream style: { error: "code" | { message, status } }
          final dynamic errorField = errorJson['error'];
          if (errorField is String) {
            // Known rate-limit codes
            if (status == 429 && errorField == 'daily_usage_limit_reached') {
              return 'Daily limit reached. Try again tomorrow.';
            }
            if (status == 429 &&
                errorField == 'per_minute_usage_limit_reached') {
              return 'Too many requests. Please wait a moment.';
            }
            return errorField;
          }
          if (errorField is Map) {
            final nestedMsg = errorField['message'];
            if (nestedMsg is String && nestedMsg.trim().isNotEmpty) {
              return nestedMsg.trim();
            }
            final nestedStatus = errorField['status']?.toString();
            if (nestedStatus != null && nestedStatus.isNotEmpty) {
              return nestedStatus;
            }
          }

          // Common alternative keys
          for (final key in ['detail', 'error_description', 'description']) {
            final val = errorJson[key];
            if (val is String && val.trim().isNotEmpty) return val.trim();
          }

          // Errors array
          final errors = errorJson['errors'];
          if (errors is List && errors.isNotEmpty) {
            final first = errors.first;
            if (first is Map) {
              final msg = first['message'] ?? first['detail'];
              if (msg is String && msg.trim().isNotEmpty) return msg.trim();
            } else if (first is String && first.trim().isNotEmpty) {
              return first.trim();
            }
          }
        }
        return '';
      }

      // Try JSON first
      try {
        final parsed = jsonDecode(bodyStr);
        final message = extractMessageFromError(parsed);
        if (message.isNotEmpty) {
          throw Exception(message);
        }
        // If we cannot find a message inside JSON, show the raw text
        final fallback = bodyStr.trim();
        throw Exception(
            fallback.isNotEmpty ? fallback : 'Request failed ($status)');
      } catch (_) {
        final fallback = bodyStr.trim();
        throw Exception(
            fallback.isNotEmpty ? fallback : 'Request failed ($status)');
      }
    } on FunctionException catch (e) {
      throw Exception('Function error: ${e.toString()}');
    } catch (e) {
      rethrow;
    }
  }
}
