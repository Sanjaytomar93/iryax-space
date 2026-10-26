import 'package:get/get.dart';

import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/notifications/model/notification_model.dart';
import 'package:iryax_spaces/modules/notifications/service/notification_service.dart';

enum NotificationFilter { all, bookings, offers, system }

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  final RxList<NotificationModel> items = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<NotificationFilter> selectedFilter = NotificationFilter.all.obs;

  final Set<String> _locallyReadIds = <String>{};

  int get unreadCount => items.where((e) => !e.isRead).length;

  bool get hasUnread => unreadCount > 0;

  @override
  void onInit() {
    super.onInit();
    _reloadLocalReadIds();
    loadNotifications();
  }

  void _reloadLocalReadIds() {
    _locallyReadIds
      ..clear()
      ..addAll(StorageService.getReadNotificationIds());
  }

  /// Stable key even when API id is missing.
  String _keyOf(NotificationModel item) {
    if (item.id.trim().isNotEmpty) return item.id.trim();
    final t = item.createdAt?.millisecondsSinceEpoch ?? 0;
    return '${item.title}|${item.message}|$t';
  }

  List<NotificationModel> get filteredItems {
    final filter = selectedFilter.value;
    if (filter == NotificationFilter.all) return items.toList();
    final key = filter.name;
    return items.where((item) => item.type == key).toList();
  }

  int countFor(NotificationFilter filter) {
    if (filter == NotificationFilter.all) return items.length;
    return items.where((item) => item.type == filter.name).length;
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    _reloadLocalReadIds();
    try {
      final list = await _service.getNotifications();
      items.assignAll(_applyLocalRead(list));
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshQuietly() async {
    _reloadLocalReadIds();
    try {
      final list = await _service.getNotifications();
      items.assignAll(_applyLocalRead(list));
      errorMessage.value = '';
    } catch (_) {}
  }

  List<NotificationModel> _applyLocalRead(List<NotificationModel> list) {
    list.sort((a, b) {
      final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bTime.compareTo(aTime);
    });

    return list.map((item) {
      final key = _keyOf(item);
      if (item.isRead) {
        _locallyReadIds.add(key);
        return item;
      }
      if (_locallyReadIds.contains(key)) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
  }

  Future<void> _persistReadIds() async {
    await StorageService.saveReadNotificationIds(_locallyReadIds);
  }

  void setFilter(NotificationFilter filter) {
    selectedFilter.value = filter;
  }

  void markAllRead() {
    for (final item in items) {
      _locallyReadIds.add(_keyOf(item));
    }
    for (var i = 0; i < items.length; i++) {
      if (!items[i].isRead) {
        items[i] = items[i].copyWith(isRead: true);
      }
    }
    items.refresh();
    _persistReadIds();
  }

  void markAsRead(NotificationModel item) {
    final key = _keyOf(item);
    _locallyReadIds.add(key);
    if (item.id.trim().isNotEmpty) {
      _locallyReadIds.add(item.id.trim());
    }

    final i = items.indexWhere(
      (e) => _keyOf(e) == key || (item.id.isNotEmpty && e.id == item.id),
    );
    if (i >= 0 && !items[i].isRead) {
      items[i] = items[i].copyWith(isRead: true);
      items.refresh();
    }
    _persistReadIds();
  }

  Future<void> deleteNotification(String id) async {
    await _deleteByIds([id]);
  }

  Future<void> _deleteByIds(List<String> ids) async {
    isDeleting.value = true;
    try {
      await _service.deleteNotifications(ids);
      final removeKeys = <String>{};
      for (final item in items) {
        if (ids.contains(item.id) || ids.contains(_keyOf(item))) {
          removeKeys.add(_keyOf(item));
          removeKeys.add(item.id);
        }
      }
      items.removeWhere(
        (item) => ids.contains(item.id) || ids.contains(_keyOf(item)),
      );
      _locallyReadIds.removeAll(removeKeys);
      await _persistReadIds();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDeleting.value = false;
    }
  }
}
