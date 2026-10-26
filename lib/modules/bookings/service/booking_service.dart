import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:iryax_spaces/core/constants/api_endpoints.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/model/site_visit_model.dart';
class BookingService {
  Future<Map<String, dynamic>> createBooking({
    required String cabinId,
    required String name,
    required String mobile,
    required String email,
    required String startDate,
    required String startTime,
    required String endDate,
    required String endTime,
    required List<String> selectedSeats,
    required double extraCharge,
    required int seatCount,
    required List<Map<String, dynamic>> bookingSlots,
    required double totalPrice,
  }) async {
    final userId = StorageService.userId.trim();
    final token = StorageService.token.trim();

    if (userId.isEmpty) {
      throw Exception('User session not found.');
    }

    final response = await http.post(
      Uri.parse(
        ApiEndpoints.createBooking(
          userId,
        ),
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'cabinId': cabinId,
        'name': name,
        'mobile': mobile,
        'email': email,
        'startDate': startDate,
        'startTime': startTime,
        'endDate': endDate,
        'endTime': endTime,
        'bookingBasis': 'hourly',
        'selectedPlan': null,
        'selectedSeats': selectedSeats,
        'extraCharge': extraCharge,
        'seatCount': seatCount,
        'paymentMethod': 'cash',
        'termsAccepted': true,
        'bookingSlots': bookingSlots,
        'totalPrice': totalPrice,
      }),
    );

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Server error: ${response.statusCode}');
    }

    if (decoded is! Map) {
      throw Exception('Invalid booking response format.');
    }

    final data = Map<String, dynamic>.from(decoded);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      return data;
    }

    // Return the actual message returned by server or fallback with status code
    final errMsg = data['message'] ??
        data['error'] ??
        data['msg'] ??
        'Unable to create booking (${response.statusCode})';
    throw Exception(errMsg.toString());
  }


  Future<Map<String, dynamic>> createVisit({
    required String cabinId,
    required String name,
    required String mobile,
    required String email,
    required String startDate,
    required String startTime,
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

    final response = await http.post(
      Uri.parse(
        ApiEndpoints.createVisit(
          userId,
        ),
      ),


      headers: {
        'Accept': 'application/json',
        'Content-Type':
        'application/json',
        if (token.isNotEmpty)
          'Authorization':
          'Bearer $token',
      },
      body: jsonEncode({
        'cabinId': cabinId,
        'name': name,
        'mobile': mobile,
        'email': email,
        'startDate': startDate,
        'startTime': startTime,
      }),
    );

    final decoded =
    jsonDecode(
      response.body,
    );

    if (decoded is! Map) {
      throw Exception(
        'Invalid site visit response.',
      );
    }

    final data =
    Map<String, dynamic>.from(
      decoded,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message']?.toString() ??
          'Unable to schedule site visit.',
    );
  }


  Future<List<BookingModel>> getUserBookings() async {
    final token = StorageService.token.trim();

    final response = await http.get(
      Uri.parse(
        ApiEndpoints.userBookings,
      ),
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! Map) {
      throw Exception(
        'Invalid bookings response.',
      );
    }

    final data =
    Map<String, dynamic>.from(
      decoded,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      final items =
          data['bookings'] as List? ?? [];

      return items
          .whereType<Map>()
          .map(
            (item) => BookingModel.fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        ),
      )
          .toList();
    }

    throw Exception(
      data['message']?.toString() ??
          'Unable to load bookings.',
    );
  }

  Future<List<SiteVisitModel>>
  getUserVisits() async {
    final token = StorageService.token.trim();

    final response = await http.get(
      Uri.parse(
        ApiEndpoints.userVisits,
      ),
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! Map) {
      throw Exception(
        'Invalid site visits response.',
      );
    }

    final data =
    Map<String, dynamic>.from(
      decoded,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      final items =
          data['bookings'] as List? ?? [];

      return items
          .whereType<Map>()
          .map(
            (item) => SiteVisitModel.fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        ),
      )
          .toList();
    }

    throw Exception(
      data['message']?.toString() ??
          'Unable to load site visits.',
    );
  }


  Future<Map<String, dynamic>> cancelBooking(
      String bookingId,
      ) async {
    final token = StorageService.token.trim();

    final response = await http.put(
      Uri.parse(
        ApiEndpoints.cancelBooking(
          bookingId,
        ),
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! Map) {
      throw Exception(
        'Invalid cancel booking response.',
      );
    }

    final data =
    Map<String, dynamic>.from(
      decoded,
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['success'] == true) {
      return data;
    }

    throw Exception(
      data['message']?.toString() ??
          'Unable to cancel booking.',
    );
  }


}
