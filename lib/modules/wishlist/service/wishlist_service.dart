import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:iryax_spaces/core/constants/api_endpoints.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/spaces/service/spaces_service.dart';

class WishlistService {
  Future<List<SpaceModel>> getWishlist() async {
    final userId = StorageService.userId.trim();
    final token = StorageService.token.trim();

    if (userId.isEmpty) {
      throw Exception('User session not found.');
    }

    final response = await http.get(
      Uri.parse(ApiEndpoints.myWishlist(userId)),
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load wishlist.');
    }

    final rawList = _extractList(decoded);
    if (rawList == null) {
      return [];
    }

    final spaces = <SpaceModel>[];
    final seen = <String>{};

    for (final item in rawList.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      final space = await _parseWishlistItem(map);
      if (space == null || space.id.isEmpty || seen.contains(space.id)) {
        continue;
      }
      seen.add(space.id);
      spaces.add(space);
    }

    return spaces;
  }

  List? _extractList(dynamic decoded) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(decoded);
    final nested = map['data'];
    final candidates = <dynamic>[
      map['data'],
      map['wishlist'],
      map['items'],
      if (nested is Map) nested['wishlist'],
      if (nested is Map) nested['items'],
      if (nested is Map) nested['data'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }

    return null;
  }

  Future<SpaceModel?> _parseWishlistItem(
    Map<String, dynamic> map,
  ) async {
    final rawSpace = map['cabin'] ?? map['space'] ?? map;

    if (rawSpace is Map) {
      final spaceMap = Map<String, dynamic>.from(rawSpace);
      if (spaceMap['_id'] == null && spaceMap['id'] != null) {
        spaceMap['_id'] = spaceMap['id'];
      }

      final space = SpaceModel.fromJson(spaceMap);
      if (space.id.isNotEmpty && space.name.trim().isNotEmpty) {
        return space;
      }
      if (space.id.isNotEmpty) {
        return await _resolveSpaceById(space.id);
      }
    }

    if (rawSpace is String && rawSpace.trim().isNotEmpty) {
      return await _resolveSpaceById(rawSpace.trim());
    }

    final cabinId = map['cabinId']?.toString().trim() ?? '';
    if (cabinId.isNotEmpty) {
      return await _resolveSpaceById(cabinId);
    }

    return null;
  }

  Future<SpaceModel?> _resolveSpaceById(String cabinId) async {
    if (Get.isRegistered<SpacesController>()) {
      final cached = Get.find<SpacesController>().spaces.firstWhereOrNull(
            (space) => space.id == cabinId,
          );
      if (cached != null) {
        return cached;
      }
    }

    try {
      return await SpacesService().getSpaceDetails(cabinId);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleWishlist(String spaceId) async {
    final userId = StorageService.userId.trim();
    final token = StorageService.token.trim();

    final response = await http.post(
      Uri.parse(ApiEndpoints.toggleWishlist(userId)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'cabinId': spaceId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to update wishlist.');
    }
  }

  Future<void> removeWishlist(String spaceId) async {
    final userId = StorageService.userId.trim();
    final token = StorageService.token.trim();

    final response = await http.delete(
      Uri.parse(
        ApiEndpoints.deleteWishlist(
          userId,
          spaceId,
        ),
      ),
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to remove wishlist item.');
    }
  }
}
