import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/modules/dashboard(home)/service/dashboard_service.dart';


class HomeController extends GetxController {
  final DashboardService _dashboardService =
  DashboardService();

  final isLoading = false.obs;

  final errorMessage = RxnString();

  final totalBookings = 0.obs;
  final totalSpent = 0.0.obs;

  final pendingBookings = 0.obs;
  final confirmedBookings = 0.obs;
  final activeBookings = 0.obs;
  final completedBookings = 0.obs;
  final cancelledBookings = 0.obs;

  final recentBookings =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final data =
      await _dashboardService
          .getUserDashboard();

      totalBookings.value =
          _toInt(
            data['totalBookings'],
          );

      totalSpent.value =
          _toDouble(
            data['totalSpent'],
          );

      final statusRaw =
      data['statusDistribution'];

      final status = statusRaw is Map
          ? Map<String, dynamic>.from(
        statusRaw,
      )
          : <String, dynamic>{};

      pendingBookings.value =
          _toInt(
            status['pending'],
          );

      confirmedBookings.value =
          _toInt(
            status['confirmed'],
          );

      activeBookings.value =
          _toInt(
            status['active'],
          );

      completedBookings.value =
          _toInt(
            status['completed'],
          );

      cancelledBookings.value =
          _toInt(
            status['cancelled'],
          );

      final recent =
      data['recentBookings'];

      if (recent is List) {
        recentBookings.assignAll(
          recent
              .whereType<Map>()
              .map(
                (item) =>
            Map<String, dynamic>.from(
              item,
            ),
          )
              .toList(),
        );
      } else {
        recentBookings.clear();
      }

      debugPrint(
        'DASHBOARD TOTAL: ${totalBookings.value}',
      );

      debugPrint(
        'DASHBOARD STATUS: '
            'pending=${pendingBookings.value}, '
            'confirmed=${confirmedBookings.value}, '
            'active=${activeBookings.value}, '
            'completed=${completedBookings.value}, '
            'cancelled=${cancelledBookings.value}',
      );

      debugPrint(
        'DASHBOARD RECENT: ${recentBookings.length}',
      );
    } catch (e) {
      errorMessage.value = e
          .toString()
          .replaceFirst(
        'Exception: ',
        '',
      );

      debugPrint(
        'DASHBOARD ERROR: ${errorMessage.value}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  double _toDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}