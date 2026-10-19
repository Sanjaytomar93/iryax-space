import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_endpoints.dart';
import '../model/login_response_model.dart';

class AuthService {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(
        ApiEndpoints.login,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      data = Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return LoginResponseModel.fromJson(
        data,
      );
    }

    throw Exception(
      data['message']?.toString() ??
          'Unable to login. Please try again.',
    );
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String mobile,
    required String address,
    required String role,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        ApiEndpoints.register,
      ),
    );

    request.headers.addAll({
      'Accept': 'application/json',
    });

    request.fields.addAll({
      'name': name,
      'email': email,
      'password': password,
      'mobile': mobile,
      'address': address,
      'role': role,
    });

    final streamedResponse =
    await request.send();

    final response =
    await http.Response.fromStream(
      streamedResponse,
    );

    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      data = Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data['message']?.toString() ??
          'Registration successful';
    }

    throw Exception(
      data['message']?.toString() ??
          'Unable to register. Please try again.',
    );
  }
}