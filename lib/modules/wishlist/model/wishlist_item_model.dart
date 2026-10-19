import 'package:iryax_spaces/modules/spaces/model/space_model.dart';

class WishlistModel {
  final String id;
  final String userId;
  final SpaceModel? space;

  const WishlistModel({
    required this.id,
    required this.userId,
    required this.space,
  });

  factory WishlistModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawSpace =
        json['cabin'] ??
            json['space'] ??
            json['cabinId'];

    return WishlistModel(
      id:
      json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      userId:
      json['userId']?.toString() ??
          json['user']?.toString() ??
          '',
      space: rawSpace is Map
          ? SpaceModel.fromJson(
        Map<String, dynamic>.from(
          rawSpace,
        ),
      )
          : null,
    );
  }
}