import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/dashboard(home)/service/dashboard_service.dart';

class HomeController extends GetxController {
  final DashboardService _dashboardService = DashboardService();

  final isLoading = false.obs;
  final errorMessage = RxnString();

  final totalBookings = 0.obs;
  final totalSpent = 0.0.obs;

  final pendingBookings = 0.obs;
  final confirmedBookings = 0.obs;
  final activeBookings = 0.obs;
  final completedBookings = 0.obs;
  final cancelledBookings = 0.obs;

  final recentBookings = <Map<String, dynamic>>[].obs;

  /// True once we painted stats from bookings while dashboard API is still slow.
  bool _paintedFromBookings = false;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  void syncWithBookings(List<BookingModel> list) {
    if (list.isEmpty) return;

    totalBookings.value = list.length;
    pendingBookings.value =
        list.where((b) => b.status == BookingStatus.pending).length;
    confirmedBookings.value =
        list.where((b) => b.status == BookingStatus.confirmed).length;
    activeBookings.value =
        list.where((b) => b.status == BookingStatus.active).length;
    completedBookings.value =
        list.where((b) => b.status == BookingStatus.completed).length;
    cancelledBookings.value =
        list.where((b) => b.status == BookingStatus.cancelled).length;

    double spent = 0;
    for (final b in list) {
      if (b.status != BookingStatus.cancelled) {
        final cleaned = b.amount.replaceAll(RegExp(r'[^0-9.]'), '');
        spent += double.tryParse(cleaned) ?? 0;
      }
    }
    totalSpent.value = spent;
      errorMessage.value = null;
  }

  Future<void> loadDashboard() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;
    _paintedFromBookings = false;

    // Show bookings stats ASAP — don't wait for slow dashboard API.
    unawaited(_paintFromBookingsWhenReady());

    try {
      final data = await _dashboardService.getUserDashboard();
      _applyDashboardPayload(data);

      debugPrint('DASHBOARD TOTAL: ${totalBookings.value}');
      debugPrint(
        'DASHBOARD STATUS: '
        'pending=${pendingBookings.value}, '
        'confirmed=${confirmedBookings.value}, '
        'active=${activeBookings.value}, '
        'completed=${completedBookings.value}, '
        'cancelled=${cancelledBookings.value}',
      );
    } catch (e) {
      debugPrint('DASHBOARD ERROR: $e');

      // Already showing bookings? Ignore timeout — UI already has data.
      if (totalBookings.value > 0 || _paintedFromBookings) {
        errorMessage.value = null;
      } else {
        final synced = await _fallbackFromBookings();
        if (!synced) {
          errorMessage.value =
              'Server timed out. Pull down to retry.';
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _applyDashboardPayload(Map<String, dynamic> data) {
      totalBookings.value = _toInt(data['totalBookings']);
      totalSpent.value = _toDouble(data['totalSpent']);

      final statusRaw = data['statusDistribution'];
      final status = statusRaw is Map
          ? Map<String, dynamic>.from(statusRaw)
          : <String, dynamic>{};

      pendingBookings.value = _toInt(status['pending']);
      confirmedBookings.value = _toInt(status['confirmed']);
      activeBookings.value = _toInt(status['active']);
      completedBookings.value = _toInt(status['completed']);
      cancelledBookings.value = _toInt(status['cancelled']);

      final recent = data['recentBookings'];
      if (recent is List) {
        recentBookings.assignAll(
          recent
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(),
        );
      } else {
        recentBookings.clear();
      }

    errorMessage.value = null;

      if (totalBookings.value == 0) {
      unawaited(_fallbackFromBookings());
    }
  }

  Future<void> _paintFromBookingsWhenReady() async {
    final ok = await _fallbackFromBookings();
    if (!ok) return;

    _paintedFromBookings = true;
    // Unlock UI immediately — dashboard API can finish later.
    isLoading.value = false;
  }

  Future<bool> _fallbackFromBookings() async {
    if (!Get.isRegistered<BookingsController>()) return false;

    final bookings = Get.find<BookingsController>();

    for (var i = 0; i < 20; i++) {
      if (bookings.bookings.isNotEmpty) {
        syncWithBookings(bookings.bookings);
        return true;
      }
      if (!bookings.isLoadingBookings.value && i > 0) break;
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (bookings.bookings.isNotEmpty) {
      syncWithBookings(bookings.bookings);
      return true;
    }
    return false;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
