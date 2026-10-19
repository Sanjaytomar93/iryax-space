import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:iryax_spaces/core/constants/api_endpoints.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';

class WishlistService {
  Future<List<SpaceModel>> getWishlist() async {
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
        ApiEndpoints.myWishlist(
          userId,
        ),
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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        final rawData =
            decoded['data'] ??
                decoded['wishlist'] ??
                [];

        if (rawData is List) {
          return rawData
              .whereType<Map>()
              .map(
                (item) {
              final map =
              Map<String, dynamic>.from(
                item,
              );

              final rawSpace =
                  map['cabin'] ??
                      map['space'] ??
                      map;

              if (rawSpace is Map) {
                return SpaceModel.fromJson(
                  Map<String, dynamic>.from(
                    rawSpace,
                  ),
                );
              }

              return null;
            },
          )
              .whereType<SpaceModel>()
              .toList();
        }
      }

      return [];
    }

    throw Exception(
      'Unable to load wishlist.',
    );
  }

  Future<void> toggleWishlist(
      String spaceId,
      ) async {
    final userId =
    StorageService.userId.trim();

    final token =
    StorageService.token.trim();

    final response =
    await http.post(
      Uri.parse(
        ApiEndpoints.toggleWishlist(
          userId,
        ),
      ),
      headers: {
        'Content-Type':
        'application/json',
        'Accept':
        'application/json',
        if (token.isNotEmpty)
          'Authorization':
          'Bearer $token',
      },
      body: jsonEncode({
        'cabinId': spaceId,
      }),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Unable to update wishlist.',
      );
    }
  }

  Future<void> removeWishlist(
      String spaceId,
      ) async {
    final userId =
    StorageService.userId.trim();

    final token =
    StorageService.token.trim();

    final response =
    await http.delete(
      Uri.parse(
        ApiEndpoints.deleteWishlist(
          userId,
          spaceId,
        ),
      ),
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty)
          'Authorization':
          'Bearer $token',
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Unable to remove wishlist item.',
      );
    }
  }
}