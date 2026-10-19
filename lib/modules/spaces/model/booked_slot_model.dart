class BookedSlotModel {
  final String id;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final String name;
  final String email;

  const BookedSlotModel({
    required this.id,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.name,
    required this.email,
  });

  factory BookedSlotModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return BookedSlotModel(
      id: json['_id']?.toString() ?? '',
      startDate:
      json['startDate']?.toString() ?? '',
      startTime:
      json['startTime']?.toString() ?? '',
      endDate:
      json['endDate']?.toString() ?? '',
      endTime:
      json['endTime']?.toString() ?? '',
      name:
      json['name']?.toString() ?? '',
      email:
      json['email']?.toString() ?? '',
    );
  }
}