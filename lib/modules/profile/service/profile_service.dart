import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:iryax_spaces/core/constants/api_endpoints.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/profile/model/profile_model.dart';

class ProfileService {
  Future<ProfileModel> getProfile() async {
    final userId =
    StorageService.userId.trim();

    final token =
    StorageService.token.trim();

    if (userId.isEmpty) {
      throw Exception(
        'User session not found.',
      );
    }

    final response = await http.get(
      Uri.parse(
        ApiEndpoints.profile(userId),
      ),
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty)
          'Authorization':
          'Bearer $token',
      },
    );

    final decoded =
    jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid profile response.',
      );
    }

    final body =
    Map<String, dynamic>.from(
      decoded,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true) {
      final rawUser = body['user'];

      if (rawUser is Map) {
        return ProfileModel.fromJson(
          Map<String, dynamic>.from(
            rawUser,
          ),
        );
      }

      throw Exception(
        'Profile data not found.',
      );
    }

    throw Exception(
      body['message']?.toString() ??
          'Unable to load profile.',
    );
  }

  Future<ProfileModel> updateProfile({
    required String name,
    required String email,
    required String mobile,
    required String address,
    required String organization,
    required String gstNumber,
  }) async {
    final userId =
    StorageService.userId.trim();

    final token =
    StorageService.token.trim();

    if (userId.isEmpty) {
      throw Exception(
        'User session not found.',
      );
    }

    final request =
    http.MultipartRequest(
      'PUT',
      Uri.parse(
        ApiEndpoints.profile(userId),
      ),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      if (token.isNotEmpty)
        'Authorization':
        'Bearer $token',
    });

    request.fields.addAll({
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'organizationName':
      organization,
      'gstNumber': gstNumber,
    });

    final streamed =
    await request.send();

    final response =
    await http.Response.fromStream(
      streamed,
    );

    final decoded =
    jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception(
        'Invalid profile update response.',
      );
    }

    final body =
    Map<String, dynamic>.from(
      decoded,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true) {
      final rawUser =
          body['user'] ??
              body['data'];

      if (rawUser is Map) {
        return ProfileModel.fromJson(
          Map<String, dynamic>.from(
            rawUser,
          ),
        );
      }

      // Some APIs update successfully without returning user.
      return getProfile();
    }

    throw Exception(
      body['message']?.toString() ??
          'Unable to update profile.',
    );
  }
}