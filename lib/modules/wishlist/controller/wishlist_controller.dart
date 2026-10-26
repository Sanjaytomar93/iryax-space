import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/wishlist/service/wishlist_service.dart';

class WishlistController extends GetxController {
  final WishlistService _wishlistService =
  WishlistService();

  final TextEditingController searchController =
  TextEditingController();

  final RxList<SpaceModel> items =
      <SpaceModel>[].obs;

  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxSet<String> updatingIds =
      <String>{}.obs;

  int get totalSaved => items.length;

  int get totalCategories {
    return items
        .map((item) => item.category)
        .where(
          (value) => value.trim().isNotEmpty,
    )
        .toSet()
        .length;
  }

  List<SpaceModel> get filteredItems {
    final query =
    searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      return items;
    }

    return items.where(
          (item) {
        return item.name
            .toLowerCase()
            .contains(query) ||
            item.location
                .toLowerCase()
                .contains(query) ||
            item.category
                .toLowerCase()
                .contains(query);
      },
    ).toList();
  }

  bool _hasLoadedOnce = false;
  bool _isLoadingWishlist = false;

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(
      _onSearchChanged,
    );

    // Load early so Spaces hearts show correct state and users don't
    // accidentally toggle items OFF thinking they are not saved.
    Future.microtask(ensureLoaded);
  }

  Future<void> ensureLoaded({bool force = false}) async {
    if (!force && (_hasLoadedOnce || _isLoadingWishlist || items.isNotEmpty)) {
      return;
    }
    await loadWishlist();
  }

  void _onSearchChanged() {
    searchQuery.value =
        searchController.text;
  }

  // ============================================================
  // LOAD WISHLIST
  // ============================================================

  Future<void> loadWishlist() async {
    if (_isLoadingWishlist) {
      return;
    }

    try {
      _isLoadingWishlist = true;
      isLoading.value = true;
      errorMessage.value = '';

      final previous = List<SpaceModel>.from(items);
      final result = await _wishlistService.getWishlist();

      // Never wipe a non-empty local list with a suspicious empty payload
      // right after a network glitch / parse miss.
      if (result.isNotEmpty || !_hasLoadedOnce || previous.isEmpty) {
        items.assignAll(result);
      }

      _hasLoadedOnce = true;
    } catch (e) {
      errorMessage.value = _friendlyError(e);
    } finally {
      _isLoadingWishlist = false;
      isLoading.value = false;
    }
  }

  Future<void> refreshWishlist() async {
    await loadWishlist();
  }

  // ============================================================
  // FAVORITE CHECK
  // ============================================================

  bool isFavorite(String spaceId) {
    return items.any(
          (item) => item.id == spaceId,
    );
  }

  bool isUpdating(String spaceId) {
    return updatingIds.contains(spaceId);
  }

  // ============================================================
  // TOGGLE FAVORITE
  // ============================================================

  Future<void> toggleFavorite(
      SpaceModel space,
      ) async {
    if (updatingIds.contains(space.id)) {
      return;
    }

    final wasFavorite =
    isFavorite(space.id);

    try {
      // Optimistic UI update first so hearts turn red immediately.
      if (wasFavorite) {
        items.removeWhere(
              (item) => item.id == space.id,
        );
      } else {
        items.add(space);
      }
      updatingIds.add(space.id);

      await _wishlistService.toggleWishlist(
        space.id,
      );

      // Soft refresh, but never drop a just-liked item if API lags.
      final result = await _wishlistService.getWishlist();
      if (result.isNotEmpty) {
        final serverHas = result.any((e) => e.id == space.id);
        if (!wasFavorite && !serverHas) {
          items.assignAll([...result, space]);
        } else {
          items.assignAll(result);
        }
        _hasLoadedOnce = true;
      }
    } catch (e) {
      // Roll back UI if API fails
      if (wasFavorite) {
        if (!isFavorite(space.id)) {
          items.add(space);
        }
      } else {
        items.removeWhere(
              (item) => item.id == space.id,
        );
      }

      Get.snackbar(
        'Wishlist',
        _friendlyError(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      updatingIds.remove(space.id);
    }
  }

  // ============================================================
  // REMOVE FROM WISHLIST
  // ============================================================

  Future<void> removeItem(
      String spaceId,
      ) async {
    if (updatingIds.contains(spaceId)) {
      return;
    }

    final index = items.indexWhere(
          (item) => item.id == spaceId,
    );

    SpaceModel? removedItem;

    if (index != -1) {
      removedItem = items[index];
    }

    try {
      updatingIds.add(spaceId);

      items.removeWhere(
            (item) => item.id == spaceId,
      );

      await _wishlistService.removeWishlist(
        spaceId,
      );

      await loadWishlist();
    } catch (e) {
      if (removedItem != null &&
          !isFavorite(spaceId)) {
        items.add(removedItem);
      }

      Get.snackbar(
        'Wishlist',
        _friendlyError(e),
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } finally {
      updatingIds.remove(spaceId);
    }
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<void> clearAll() async {
    if (items.isEmpty) {
      return;
    }

    final existingItems =
    List<SpaceModel>.from(items);

    try {
      isLoading.value = true;

      for (final item in existingItems) {
        await _wishlistService.removeWishlist(
          item.id,
        );
      }

      items.clear();

      Get.snackbar(
        'Wishlist Cleared',
        'All saved spaces have been removed.',
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } catch (e) {
      await loadWishlist();

      Get.snackbar(
        'Unable to Clear Wishlist',
        _friendlyError(e),
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _friendlyError(
      Object error,
      ) {
    final message =
    error.toString();

    final lower =
    message.toLowerCase();

    if (lower.contains('socketfailed') ||
        lower.contains(
          'failed host lookup',
        ) ||
        lower.contains(
          'no address associated',
        )) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    if (lower.contains('timeout')) {
      return 'The request took too long. Please try again.';
    }

    return message.replaceFirst(
      'Exception: ',
      '',
    );
  }

  @override
  void onClose() {
    searchController.removeListener(
      _onSearchChanged,
    );

    searchController.dispose();

    super.onClose();
  }
}
