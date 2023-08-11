import 'dart:io';

import 'package:chat_app/core/chat/chat_screen.dart';
import 'package:chat_app/middleware/InternetConnectionChecker.dart';
import 'package:chat_app/middleware/auth/otp_verification.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/enums.dart';
import 'package:chat_app/ui/overlay/loading_overlay.dart';
import 'package:chat_app/ui/overlay/toast.dart';
import 'package:chat_app/ui/widget/chat_field.dart';
import 'package:chat_app/ui/widget/form_validators.dart';
import 'package:chat_app/ui/widget/primary_button.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:device_info/device_info.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key, this.email}) : super(key: key);
  final String? email;

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeConfirmationController =
      TextEditingController();
  var _buttonState = AccountButtonState.disabled;
  late SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff13999a),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                StringValue.verification,
                style: Theme.of(context).textTheme.headline6,
              ),
              Padding(padding: EdgeInsets.only(top: 16)),
              Form(
                  key: _formKey,
                  onChanged: updateButtonState,
                  child: AccountText(
                      icon: Icons.lock_outline,
                      placeholderText: StringValue.verification_code,
                      textController: _codeConfirmationController,
                      obscureText: true,
                      otpVerification: true,
                      validation: FormValidators.validatePasswordResetCode)),
              Padding(padding: EdgeInsets.all(16)),
              PrimaryButton(
                  title: StringValue.verify,
                  buttonState: _buttonState,
                  onTap: () async {
                    bool isNetwork = await Network.isInternetAvailable();

                    FocusScope.of(context).requestFocus(FocusNode());
                    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                    String? deviceUUID;

                    if (Platform.isAndroid) {
                      await deviceInfo.androidInfo.then((value) {
                        deviceUUID = value.androidId;
                      });
                    }

                    if (Platform.isIOS) {
                      await deviceInfo.iosInfo.then((value) {
                        deviceUUID = value.identifierForVendor;
                      });
                    }

                    if (isNetwork) {
                      ApiRepose apiRepose = await LoadingOverlay.of(context)
                          .during(
                              OtpVerificationApi.verify(new OtpVerificationBody(
                        email: widget.email,
                        otp: int.parse(_codeConfirmationController.text),
                        fcmToken: "fcmToken",
                        deviceType: Platform.isAndroid
                            ? EnumToString.convertToString(DeviceType.ANDROID)
                            : Platform.isIOS
                                ? EnumToString.convertToString(
                                    DeviceType.IPHONE)
                                : EnumToString.convertToString(DeviceType.ANY),
                        deviceuuid: deviceUUID.toString(),
                      )));

                      if (apiRepose.statusCode == 200) {
                        //Shared Prefrences-------
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('login', true);
                        ToastModel.successToast(msg: "${apiRepose.message}");
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen()),
                            (route) => false);
                      } else {
                        ToastModel.errorToast(msg: "${apiRepose.message}");
                      }
                    } else {
                      ToastModel.errorToast(
                          msg: StringValue.internetConnectionError);
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void updateButtonState() {
    setState(() {
      _buttonState = _formKey.currentState!.validate()
          ? AccountButtonState.enabled
          : AccountButtonState.disabled;
    });
  }

  @override
  void dispose() {
    _codeConfirmationController.dispose();
    super.dispose();
  }
}
