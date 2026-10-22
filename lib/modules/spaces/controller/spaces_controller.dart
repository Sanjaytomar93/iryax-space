import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/spaces/service/spaces_service.dart';
import 'package:iryax_spaces/modules/wishlist/controller/wishlist_controller.dart';

class SpacesController extends GetxController {
  final SpacesService _spacesService = SpacesService();

  final searchController = TextEditingController();

  final selectedCategory = 'Co-Working'.obs;

  final selectedCabinType = 'All Cabin Types'.obs;

  final selectedFilter = 'All'.obs;

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
  }

  void changeCabinType(String value) {
    selectedCabinType.value = value;
  }

  void changeFilter(String value) {
    selectedFilter.value = value;
  }

  void _onSearchChanged() {
    // Forces Obx widgets depending on
    // filteredSpaces to rebuild.
    spaces.refresh();
  }

  List<SpaceModel> get filteredSpaces {
    Iterable<SpaceModel> result = spaces;

    // ============================================================
    // CATEGORY
    // ============================================================

    if (selectedCategory.value == 'Co-Working') {
      result = result.where((space) {
        return !space.isChamber || space.type?.toLowerCase() == 'coworking';
      });
    } else if (selectedCategory.value == 'Medical Chambers') {
      result = result.where((space) => space.isChamber);
    } else if (selectedCategory.value == 'Cafe & Dining') {
      result = result.where((space) => space.isCafe);
    }

    if (selectedCategory.value == 'Private Offices') {
      result = result.where((space) => space.isExclusive);
    }

    if (selectedCategory.value == 'Meeting Rooms') {
      // Backend response currently does not provide
      // a dedicated meeting-room identifier.
      result = <SpaceModel>[];
    }

    // ============================================================
    // CABIN TYPE
    // ============================================================

    if (selectedCabinType.value != 'All Cabin Types') {
      final selected = selectedCabinType.value.toLowerCase();

      result = result.where((space) {
        return space.cabinType.toLowerCase() == selected;
      });
    }

    // ============================================================
    // SEARCH
    // ============================================================

    final query = searchController.text.trim().toLowerCase();

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

    switch (selectedFilter.value) {
      case 'New Added':
        list.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(2000);

          final bDate = b.createdAt ?? DateTime(2000);

          return bDate.compareTo(aDate);
        });
        break;

      // Ratings and proximity are not supplied by the spaces API yet. Keep
      // the server order for these two UI filters until that data is exposed.
      case 'Top Rated':
      case 'Nearest':
      case 'All':
      default:
        break;
    }

    return list;
  }

  List<SpaceModel> get coworkingSpaces {
    return spaces.where((space) {
      return !space.isChamber || space.type?.toLowerCase() == 'coworking';
    }).toList();
  }

  List<SpaceModel> get medicalChambers {
    return spaces.where((space) => space.isChamber).toList();
  }

  List<SpaceModel> get cafeAndDiningSpaces {
    return spaces.where((space) => space.isCafe).toList();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void clearFilters() {
    searchController.clear();

    selectedCategory.value = 'Co-Working';

    selectedCabinType.value = 'All Cabin Types';

    selectedFilter.value = 'All';

    spaces.refresh();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);

    searchController.dispose();

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
