import 'dart:convert';

import 'package:chat_app/config/app_config.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/enums.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:dio/dio.dart';

class OtpVerificationApi {
  static Dio get _dio => Dio();

  static Future<ApiRepose> verify(OtpVerificationBody body) async {
    try {
      var response = await _dio.post(AppConfig.otpVerificationUrl, data: {
        StringValue.emailfield: body.email,
        StringValue.otp: body.otp,
        StringValue.fcmToken: body.fcmToken,
        StringValue.deviceuuid: body.deviceuuid,
        StringValue.deviceType: body.deviceType,
      });
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(response.data)),
        statusCode: response.statusCode!,
        api: AppApi.OTP,
      );
    } on DioError catch (e) {
      return ApiRepose.fromJson(
        jsonDecode(jsonEncode(e.response!.data)),
        statusCode: e.response!.statusCode!,
        api: AppApi.OTP,
      );
    }
  }
}

class OtpVerificationBody {
  String? email;
  int? otp;
  String? fcmToken;
  String? deviceuuid;
  String? deviceType;

  OtpVerificationBody({
    required this.email,
    required this.otp,
    this.fcmToken,
    this.deviceType,
    this.deviceuuid,
  });
}
