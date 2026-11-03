import 'package:mystore/features/authentication/me/me_model.dart';

class LoginModel {
  final UserModel user;
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  LoginModel({
    required this.user,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] ?? {};
    return LoginModel(
      user: UserModel.fromJson(data['user'] ?? {}),
      accessToken: data['access_token'] ?? '',
      tokenType: data['token_type'] ?? '',
      expiresIn: data['expires_in'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'user': user.toJson(),
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
      },
    };
  }
}
