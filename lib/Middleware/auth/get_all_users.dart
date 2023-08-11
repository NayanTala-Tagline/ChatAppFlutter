import 'dart:convert';

import 'package:chat_app/config/app_config.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/enums.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetAllUsers {
  static Dio get _dio => Dio();

  static Future<ApiRepose> getAllUser({required int page}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString(StringValue.accessToken);
      var response = await _dio.get(
        AppConfig.getAllUserUrl + "?page=$page&perPage=20",
        options: Options(headers: {StringValue.authorization: accessToken!}),
      );
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(response.data)),
        statusCode: response.statusCode!,
        api: AppApi.GETALLUSERS,
      );
    } on DioError catch (e) {
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(e.response!.data)),
        statusCode: e.response!.statusCode!,
        api: AppApi.GETALLUSERS,
      );
    }
  }
}
