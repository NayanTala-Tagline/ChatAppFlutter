import 'dart:convert';

import 'package:chat_app/config/app_config.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/enums.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendConnectionRequest {
  static Dio get _dio => Dio();

  static Future<ApiRepose> sendConnectionRequest(
      SendConnectionsBody body) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString(StringValue.accessToken);
      var response = await _dio.post(AppConfig.getSentConnectionRequestUrl,
          data: {
            StringValue.userid: body.userId,
            StringValue.connectionId: body.connectionId,
            StringValue.status: body.status,
          },
          options: Options(
            headers: {StringValue.authorization: accessToken!},
          ));
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(response.data)),
        statusCode: response.statusCode!,
        api: AppApi.SENDCONNECTIONREQUEST,
      );
    } on DioError catch (e) {
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(e.response!.data)),
        statusCode: e.response!.statusCode!,
        api: AppApi.SENDCONNECTIONREQUEST,
      );
    }
  }
}

class SendConnectionsBody {
  String userId;
  String connectionId;
  String status;

  SendConnectionsBody(
      {required this.userId, required this.connectionId, required this.status});
}
