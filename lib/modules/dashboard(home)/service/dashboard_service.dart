import 'dart:convert';

import 'package:http/http.dart'
as http;

import 'package:iryax_spaces/core/constants/api_endpoints.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';

class DashboardService {
  Future<Map<String, dynamic>>
  getUserDashboard() async {
    final token =
    StorageService.token.trim();

    final response =
    await http.get(
      Uri.parse(
        ApiEndpoints.userDashboard,
      ),
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty)
          'Authorization':
          'Bearer $token',
      },
    );

    final decoded =
    jsonDecode(
      response.body,
    );

    if (decoded is! Map) {
      throw Exception(
        'Invalid dashboard response.',
      );
    }

    final body =
    Map<String, dynamic>.from(
      decoded,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true) {
      final data =
      body['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(
          data,
        );
      }

      throw Exception(
        'Dashboard data not found.',
      );
    }

    throw Exception(
      body['message']?.toString() ??
          'Unable to load dashboard.',
    );
  }
}