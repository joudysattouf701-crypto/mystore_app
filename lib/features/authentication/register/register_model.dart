import 'package:mystore/features/authentication/me/me_model.dart';

class RegisterModel {
  final UserModel user;
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  RegisterModel({
    required this.user,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  // السيرفر يرجع التوكن مع التسجيل مباشرة، فلا نحتاج طلب دخول بعده
  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] ?? {};
    return RegisterModel(
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
