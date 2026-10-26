import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:iryax_spaces/core/constants/api_endpoints.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/notifications/model/notification_model.dart';

class NotificationService {
  Future<List<NotificationModel>> getNotifications() async {
    final userId = StorageService.userId.trim();
    final token = StorageService.token.trim();

    if (userId.isEmpty) {
      throw Exception('User session not found.');
    }

    final response = await http.get(
      Uri.parse(ApiEndpoints.getNotifications(userId)),
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    final decoded = _decodeJson(response.body);
    if (decoded == null) {
      throw Exception(_httpFallbackMessage(response.statusCode));
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _errorMessage(decoded) ?? _httpFallbackMessage(response.statusCode),
      );
    }

    final rawList = _extractList(decoded);
    if (rawList == null) return [];

    return rawList
        .whereType<Map>()
        .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  Future<void> deleteNotifications(List<String> notificationIds) async {
    final userId = StorageService.userId.trim();
    final token = StorageService.token.trim();

    if (userId.isEmpty) {
      throw Exception('User session not found.');
    }
    if (notificationIds.isEmpty) return;

    final response = await http.delete(
      Uri.parse(ApiEndpoints.deleteNotifications(userId)),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'notificationIds': notificationIds}),
    );

    if (response.body.trim().isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) return;
      throw Exception(_httpFallbackMessage(response.statusCode));
    }

    final decoded = _decodeJson(response.body);
    if (decoded == null) {
      throw Exception(_httpFallbackMessage(response.statusCode));
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _errorMessage(decoded) ?? _httpFallbackMessage(response.statusCode),
      );
    }
  }

  dynamic _decodeJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('<!') || trimmed.startsWith('<html')) {
      return null;
    }
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return null;
    }
  }

  String _httpFallbackMessage(int statusCode) {
    if (statusCode == 404) {
      return 'Notifications API not available on server yet.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'Please login again to view notifications.';
    }
    return 'Unable to load notifications. Please try again.';
  }

  List? _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map) return null;

    final map = Map<String, dynamic>.from(decoded);
    final nested = map['data'];
    final candidates = <dynamic>[
      map['notifications'],
      map['data'],
      map['items'],
      map['results'],
      if (nested is Map) nested['notifications'],
      if (nested is Map) nested['items'],
      if (nested is Map) nested['data'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) return candidate;
    }
    return null;
  }

  String? _errorMessage(dynamic decoded) {
    if (decoded is! Map) return null;
    final map = Map<String, dynamic>.from(decoded);
    final message = map['message'] ?? map['error'] ?? map['msg'];
    if (message == null) return null;
    final text = message.toString().trim();
    return text.isEmpty ? null : text;
  }
}
