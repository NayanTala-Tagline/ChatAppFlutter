import 'dart:convert';

import 'package:chat_app/config/app_config.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/enums.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:dio/dio.dart';

class SignUpApi {
  static Dio get _dio => Dio();

  static Future<ApiRepose> signUp(SignUpBody body) async {
    try {
      Map<String, dynamic> data;
      if (body.providerType != "NORMAL") {
        data = {
          StringValue.usernamefield: body.userName,
          StringValue.emailfield: body.email,
          StringValue.providerType: body.providerType,
          "socialInfo": body.socialInfo,
        };
      } else {
        data = {
          StringValue.usernamefield: body.userName,
          StringValue.emailfield: body.email,
          StringValue.dob: body.dob,
          StringValue.passwordfield: body.password,
          StringValue.gender: body.gender,
          StringValue.providerType: body.providerType,
          "socialInfo": body.socialInfo,
        };
      }

      var response = await _dio.post(AppConfig.signUpUrl, data: data);

      // Status code : 200, 400, 500, 401
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(response.data)),
        statusCode: response.statusCode!,
        api: AppApi.SIGNUP,
      );
    } on DioError catch (e) {
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(e.response!.data)),
        statusCode: e.response!.statusCode!,
        api: AppApi.SIGNUP,
      );
    }
  }
}

class SignUpBody {
  String? userName;
  String? email;
  String? dob;
  String? password;
  String? gender;
  String? providerType;
  String? socialInfo;

  SignUpBody({
    this.userName,
    required this.email,
    this.dob,
    this.password,
    this.gender,
    this.providerType,
    this.socialInfo,
  });
}
