import 'dart:convert';

import 'package:chat_app/config/app_config.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/enums.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:dio/dio.dart';

class SignInApi {
  static Dio get _dio => Dio();

  static Future<ApiRepose> signIn(
      {required String email,
      required String password,
      String? deviceType}) async {
    try {
      var response = await _dio.post(AppConfig.signInUrl, data: {
        StringValue.emailfield: email,
        StringValue.passwordfield: password,
      });
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(response.data)),
        statusCode: response.statusCode!,
        api: AppApi.LOGIN,
      );
    } on DioError catch (e) {
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(e.response!.data)),
        statusCode: e.response!.statusCode!,
        api: AppApi.LOGIN,
      );
    }
  }
}
