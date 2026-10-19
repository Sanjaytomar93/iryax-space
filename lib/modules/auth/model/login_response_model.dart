import 'auth_user_model.dart';

class LoginResponseModel {
  final String message;
  final String token;
  final AuthUserModel user;

  const LoginResponseModel({
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoginResponseModel(
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      user: AuthUserModel.fromJson(
        Map<String, dynamic>.from(
          json['user'] ?? {},
        ),
      ),
    );
  }
}