import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iryax_spaces/core/constants/api_endpoints.dart';
import 'package:iryax_spaces/modules/spaces/model/booked_slot_model.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';

class SpacesService {
  Future<List<SpaceModel>> getSpaces() async {
    final response = await http.get(
      Uri.parse(
        ApiEndpoints.cabins,
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded = jsonDecode(
        response.body,
      );

      if (decoded is! List) {
        throw Exception(
          'Invalid spaces response.',
        );
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => SpaceModel.fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        ),
      )
          .toList();
    }

    throw Exception(
      'Unable to load spaces.',
    );
  }

  Future<SpaceModel> getSpaceDetails(
      String cabinId,
      ) async {
    final response = await http.get(
      Uri.parse(
        ApiEndpoints.cabinDetails(
          cabinId,
        ),
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded = jsonDecode(
        response.body,
      );

      if (decoded is! Map) {
        throw Exception(
          'Invalid space response.',
        );
      }

      return SpaceModel.fromJson(
        Map<String, dynamic>.from(
          decoded,
        ),
      );
    }

    throw Exception(
      'Unable to load space details.',
    );
  }

  Future<List<BookedSlotModel>>
  getBookedSlots(
      String cabinId,
      ) async {
    final response = await http.get(
      Uri.parse(
        ApiEndpoints.cabinBookedSlots(
          cabinId,
        ),
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded = jsonDecode(
        response.body,
      );

      if (decoded is! Map) {
        throw Exception(
          'Invalid booked slots response.',
        );
      }

      final data =
      Map<String, dynamic>.from(
        decoded,
      );

      return (data['bookedSlots']
      as List? ??
          [])
          .whereType<Map>()
          .map(
            (item) =>
            BookedSlotModel.fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
      )
          .toList();
    }

    throw Exception(
      'Unable to load booked slots.',
    );
  }
}