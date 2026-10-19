class AuthUserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final bool isDoctor;
  final String role;

  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.isDoctor,
    required this.role,
  });

  factory AuthUserModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AuthUserModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      isDoctor: json['isDoctor'] == true,
      role: json['role']?.toString() ?? '',
    );
  }
}