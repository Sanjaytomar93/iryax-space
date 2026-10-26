import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/spaces/service/spaces_service.dart';
import 'package:iryax_spaces/modules/wishlist/controller/wishlist_controller.dart';

class SpacesController extends GetxController {
  final SpacesService _spacesService = SpacesService();

  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final cardsSectionKey = GlobalKey();

  final searchQuery = ''.obs;

  final selectedCategory = 'All Spaces'.obs;

  final selectedCabinType = 'All Cabin Types'.obs;

  final selectedFilter = 'All Spaces'.obs;

  final spaces = <SpaceModel>[].obs;

  final isLoading = false.obs;

  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(_onSearchChanged);

    getSpaces();
  }

  Future<void> getSpaces() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await _spacesService.getSpaces();

      spaces.assignAll(result);

      if (Get.isRegistered<WishlistController>()) {
        Get.find<WishlistController>().ensureLoaded();
      }
    } catch (e) {
      errorMessage.value = _cleanError(e);

      spaces.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSpaces() async {
    try {
      errorMessage.value = null;

      final result = await _spacesService.getSpaces();

      spaces.assignAll(result);
    } catch (e) {
      errorMessage.value = _cleanError(e);
    }
  }

  void changeCategory(String value) {
    selectedCategory.value = value;
    // Avoid empty Private / Meeting lists when "Normal" cabin filter is on.
    selectedCabinType.value = 'All Cabin Types';
  }

  void changeCabinType(String value) {
    selectedCabinType.value = value;
  }

  void changeFilter(String value) {
    selectedFilter.value = value;
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim();
  }

  void scrollToSpaceCards() {
    final ctx = cardsSectionKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  bool _isCoworkingSpace(SpaceModel space) {
    return !space.isChamber && !space.isCafe && !space.isExclusive;
  }

  bool _matchesCabinType(SpaceModel space, String selected) {
    final cabin = space.cabinType.toLowerCase().trim();
    if (selected == 'exclusive') {
      return space.isExclusive;
    }
    if (selected == 'normal') {
      return !space.isExclusive &&
          (cabin.isEmpty || cabin == 'normal' || cabin == 'standard');
    }
    return cabin == selected;
  }

  bool _matchesCategory(SpaceModel space, String category) {
    switch (category) {
      case 'All':
      case 'All Spaces':
        // Show every space (active filter applied later).
        return true;
      case 'Co-Working':
        return _isCoworkingSpace(space);
      case 'Medical Chambers':
        return space.isChamber;
      case 'Cafe & Dining':
        // Strict API flag only.
        return space.isCafe;
      case 'Private Offices':
        // All exclusive cabins.
        return space.isExclusive;
      case 'Meeting Rooms':
        // Show all spaces under Meeting (API has no dedicated meeting flag).
        return true;
      default:
        return true;
    }
  }

  List<SpaceModel> get filteredSpaces {
    // Touch reactive fields so Obx always rebuilds on filter/search changes.
    final category = selectedCategory.value;
    final cabinType = selectedCabinType.value;
    final sortFilter = selectedFilter.value;
    final query = searchQuery.value.toLowerCase();
    final source = spaces.toList();

    Iterable<SpaceModel> result = source;

    // ============================================================
    // CATEGORY
    // ============================================================

    result = result.where((space) => _matchesCategory(space, category));

    // ============================================================
    // CABIN TYPE
    // ============================================================

    // Private Offices are exclusive — don't apply "Normal" cabin filter.
    final applyCabinType = cabinType != 'All Cabin Types' &&
        category != 'Private Offices' &&
        category != 'Meeting Rooms';

    if (applyCabinType) {
      final selected = cabinType.toLowerCase();
      result = result.where((space) => _matchesCabinType(space, selected));
    }

    // ============================================================
    // SEARCH
    // ============================================================

    if (query.isNotEmpty) {
      result = result.where((space) {
        return space.name.toLowerCase().contains(query) ||
            space.address.toLowerCase().contains(query) ||
            space.description.toLowerCase().contains(query) ||
            space.cabinType.toLowerCase().contains(query);
      });
    }

    // ============================================================
    // ACTIVE ONLY
    // ============================================================

    result = result.where((space) => space.isActive);

    // ============================================================
    // SORT/FILTER
    // ============================================================

    final list = result.toList();

    switch (sortFilter) {
      case 'New Added':
        list.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        break;
      // Ratings / proximity not in API yet — keep server order.
      case 'Top Rated':
      case 'Nearest':
      case 'All Spaces':
      case 'All':
      default:
        break;
    }

    return list;
  }

  List<SpaceModel> get coworkingSpaces {
    return spaces
        .where((space) => _isCoworkingSpace(space) && space.isActive)
        .toList();
  }

  List<SpaceModel> get medicalChambers {
    return spaces
        .where((space) => space.isChamber && space.isActive)
        .toList();
  }

  List<SpaceModel> get cafeAndDiningSpaces {
    return spaces
        .where((space) => space.isCafe && space.isActive)
        .toList();
  }

  List<SpaceModel> get meetingRooms {
    // Meeting shows all active spaces (same as filter).
    return spaces.where((space) => space.isActive).toList();
  }

  List<SpaceModel> get privateOffices {
    return spaces
        .where((space) => space.isExclusive && space.isActive)
        .toList();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';

    selectedCategory.value = 'All Spaces';

    selectedCabinType.value = 'All Cabin Types';

    selectedFilter.value = 'All Spaces';
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';

// import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
//
//
// class SpacesController extends GetxController {
//   final searchController = TextEditingController();
//
//   final selectedCategory = 'Co-Working'.obs;
//   final selectedCabinType = 'All Cabin Types'.obs;
//   final selectedFilter = 'All'.obs;
//
//   final spaces = <SpaceModel>[
//     const SpaceModel(
//       id: '1',
//       name: 'genz work space - Cabin-7',
//       category: 'Workspace',
//       location: 'Road No. 48',
//       imageUrl:
//       'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
//       price: '₹2100',
//       timing: '9:00 AM - 9:00 PM',
//       rating: 4.8,
//       reviews: 24,
//       seats: 5,
//     ),
//     const SpaceModel(
//       id: '2',
//       name: 'Sri Sai Balaji Apartment - 3 floor',
//       category: 'Private Office',
//       location: 'Flat No:301',
//       imageUrl:
//       'https://images.unsplash.com/photo-1497366811353-6870744d04b2',
//       price: '₹2,500',
//       timing: '9:00 AM - 9:00 PM',
//       rating: 4.8,
//       reviews: 24,
//       seats: 4,
//       isExclusive: true,
//     ),
//     const SpaceModel(
//       id: '3',
//       name: 'tech cabin - bn',
//       category: 'Workspace',
//       location: 'Hyderabad',
//       imageUrl:
//       'https://images.unsplash.com/photo-1497366216548-37526070297c',
//       price: '₹100',
//       timing: '10:00 AM - 9:00 PM',
//       rating: 4.8,
//       reviews: 24,
//       seats: 5,
//     ),
//     const SpaceModel(
//       id: '4',
//       name: 'Test - Cabin-2',
//       category: 'Workspace',
//       location: 'Road No. 48',
//       imageUrl:
//       'https://images.unsplash.com/photo-1497366412874-3415097a27e7',
//       price: '₹99',
//       timing: '9:00 AM - 9:00 PM',
//       rating: 4.8,
//       reviews: 24,
//       seats: 5,
//     ),
//     const SpaceModel(
//       id: '5',
//       name: 'Z fb bdn x - Kyu jbm',
//       category: 'Medical Chamber',
//       location: 'Did ch kk vnndm',
//       imageUrl:
//       'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d',
//       price: '₹6,52,816',
//       timing: '9:00 AM - 9:00 PM',
//       rating: 4.8,
//       reviews: 24,
//       seats: 82,
//     ),
//   ].obs;
//
//   void changeCategory(String value) {
//     selectedCategory.value = value;
//   }
//
//   void changeCabinType(String value) {
//     selectedCabinType.value = value;
//   }
//
//   void changeFilter(String value) {
//     selectedFilter.value = value;
//   }
//
//   @override
//   void onClose() {
//     searchController.dispose();
//     super.onClose();
//   }
// }
