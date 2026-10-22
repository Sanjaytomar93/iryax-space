class SpaceModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;

  final int capacity;
  final double price;

  final String address;
  final String cabinType;

  final String? cabin;
  final String? tableNumber;

  final bool isCafe;
  final bool isChamber;
  final bool isActive;
  final bool is24x7;

  final String openTime;
  final String closeTime;

  final DateTime? expiryDate;
  final DateTime? createdAt;

  final String? type;

  final List<String> images;
  final List<String> videos;

  final List<SeatModel> seats;
  final List<PricingPlanModel> pricingPlans;

  final AmenitiesModel amenities;

  const SpaceModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.capacity,
    required this.price,
    required this.address,
    required this.cabinType,
    required this.cabin,
    required this.tableNumber,
    required this.isCafe,
    required this.isChamber,
    required this.isActive,
    required this.is24x7,
    required this.openTime,
    required this.closeTime,
    required this.expiryDate,
    required this.createdAt,
    required this.type,
    required this.images,
    required this.videos,
    required this.seats,
    required this.pricingPlans,
    required this.amenities,
  });

  factory SpaceModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final parsedCapacity = int.tryParse(
      json['capacity']?.toString() ?? '',
    ) ?? 0;

    return SpaceModel(
      id: json['_id']?.toString() ?? '',
      ownerId: json['owner']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description:
      json['description']?.toString() ?? '',

      capacity: parsedCapacity,

      price: double.tryParse(
        json['price']?.toString() ?? '',
      ) ??
          0,

      address:
      json['address']?.toString() ?? '',

      cabinType:
      json['cabinType']?.toString() ?? '',

      cabin:
      json['cabin']?.toString(),

      tableNumber:
      json['tableNumber']?.toString(),

      isCafe:
      json['isCafe'] == true,

      isChamber:
      json['isChamber'] == true,

      isActive:
      json['isActive'] == true,

      is24x7:
      json['is24x7'] == true,

      openTime:
      json['openTime']?.toString() ?? '',

      closeTime:
      json['closeTime']?.toString() ?? '',

      expiryDate:
      DateTime.tryParse(
        json['expiryDate']?.toString() ?? '',
      ),

      createdAt:
      DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),

      type:
      json['type']?.toString(),

      images: (json['images'] as List? ?? [])
          .map(
            (e) => e.toString(),
      )
          .toList(),

      videos: (json['videos'] as List? ?? [])
          .map(
            (e) => e.toString(),
      )
          .toList(),

      seats: _parseSeats(json['seats'], parsedCapacity),

      pricingPlans:
      (json['pricingPlans'] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) =>
            PricingPlanModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
      )
          .toList(),

      amenities: AmenitiesModel.fromJson(
        Map<String, dynamic>.from(
          json['amenities'] ?? {},
        ),
      ),
    );
  }

  static List<SeatModel> _parseSeats(dynamic rawSeats, int capacity) {
    final list = <SeatModel>[];

    if (rawSeats is List && rawSeats.isNotEmpty) {
      for (var i = 0; i < rawSeats.length; i++) {
        final item = rawSeats[i];
        if (item is Map) {
          list.add(SeatModel.fromJson(Map<String, dynamic>.from(item)));
        } else if (item != null) {
          final str = item.toString();
          final numVal = int.tryParse(str) ?? (i + 1);
          list.add(SeatModel(
            id: str,
            name: numVal > 0 ? '$numVal' : str,
            number: numVal,
          ));
        }
      }
    } else if (rawSeats is num || (rawSeats is String && int.tryParse(rawSeats) != null)) {
      final count = int.tryParse(rawSeats.toString()) ?? 0;
      for (var i = 1; i <= count; i++) {
        list.add(SeatModel(
          id: '$i',
          name: '$i',
          number: i,
        ));
      }
    }

    // Fallback: If no explicit seat items found in backend data but capacity > 0, generate seats
    if (list.isEmpty && capacity > 0) {
      for (var i = 1; i <= capacity; i++) {
        list.add(SeatModel(
          id: '$i',
          name: '$i',
          number: i,
        ));
      }
    }

    return list;
  }

  bool get isMedicalChamber =>
      isChamber;

  bool get isCoworking {
    return !isChamber ||
        type?.toLowerCase() == 'coworking';
  }

  bool get isExclusive =>
      cabinType.toLowerCase() ==
          'exclusive';

  int get seatCount {
    if (seats.isNotEmpty) {
      return seats.length;
    }

    return capacity;
  }

  List<SeatModel> get effectiveSeats {
    if (seats.isNotEmpty) {
      return seats;
    }
    final count = seatCount > 0 ? seatCount : capacity;
    if (count > 0) {
      return List.generate(
        count,
        (i) => SeatModel(
          id: '${i + 1}',
          name: '${i + 1}',
          number: i + 1,
        ),
      );
    }
    return [];
  }

  String get timing {
    if (is24x7) {
      return '24/7';
    }

    if (openTime.isEmpty &&
        closeTime.isEmpty) {
      return '';
    }

    return '$openTime - $closeTime';
  }

  String get category {
    if (isChamber) {
      return 'Medical Chamber';
    }

    if (isCafe) {
      return 'Cafe Workspace';
    }

    if (isExclusive) {
      return 'Private Office';
    }

    return 'Workspace';
  }

  String get location => address;

  String get imageUrl {
    if (images.isEmpty) {
      return '';
    }

    final path = images.first.trim();

    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    final normalized =
    path.replaceAll('\\', '/');

    return 'https://spaceapi.iryax.com/$normalized';
  }

  /// API currently does not provide ratings.
  double get rating => 0.0;

  /// API currently does not provide review counts.
  int get reviews => 0;

  String get formattedPrice {
    if (price % 1 == 0) {
      return '₹${price.toInt()}';
    }

    return '₹${price.toStringAsFixed(2)}';
  }
}



class SeatModel {
  final String id;
  final String name;
  final int number;

  const SeatModel({
    required this.id,
    required this.name,
    required this.number,
  });

  factory SeatModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final idVal = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final numVal = int.tryParse(
      json['number']?.toString() ?? json['seatNumber']?.toString() ?? '',
    ) ?? 0;
    final nameVal = json['name']?.toString() ?? '';

    return SeatModel(
      id: idVal.isNotEmpty ? idVal : (numVal > 0 ? '$numVal' : nameVal),
      name: nameVal.isNotEmpty ? nameVal : (numVal > 0 ? '$numVal' : 'Seat'),
      number: numVal,
    );
  }
}



class PricingPlanModel {
  final String id;
  final String label;
  final double hours;
  final double cost;
  final double validity;

  const PricingPlanModel({
    required this.id,
    required this.label,
    required this.hours,
    required this.cost,
    required this.validity,
  });

  factory PricingPlanModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PricingPlanModel(
      id: json['_id']?.toString() ?? '',
      label:
      json['label']?.toString() ?? '',
      hours: double.tryParse(
        json['hours']?.toString() ?? '',
      ) ??
          0,
      cost: double.tryParse(
        json['cost']?.toString() ?? '',
      ) ??
          0,
      validity: double.tryParse(
        json['validity']?.toString() ??
            '',
      ) ??
          0,
    );
  }
}


class AmenitiesModel {
  final bool wifi;
  final bool parking;
  final bool lockers;
  final bool comfortSeating;
  final bool privateWashroom;
  final bool secureAccess;
  final bool coffee;
  final bool gym;
  final bool ac;
  final bool tv;
  final bool printer;
  final bool phone;

  const AmenitiesModel({
    required this.wifi,
    required this.parking,
    required this.lockers,
    required this.comfortSeating,
    required this.privateWashroom,
    required this.secureAccess,
    required this.coffee,
    required this.gym,
    required this.ac,
    required this.tv,
    required this.printer,
    required this.phone,
  });

  factory AmenitiesModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AmenitiesModel(
      wifi: json['wifi'] == true,
      parking: json['parking'] == true,
      lockers: json['lockers'] == true,
      comfortSeating:
      json['comfortSeating'] == true,
      privateWashroom:
      json['privateWashroom'] == true,
      secureAccess:
      json['secureAccess'] == true,
      coffee:
      json['coffee'] == true,
      gym:
      json['gym'] == true,
      ac:
      json['ac'] == true,
      tv:
      json['tv'] == true,
      printer:
      json['printer'] == true,
      phone:
      json['phone'] == true,
    );
  }
}