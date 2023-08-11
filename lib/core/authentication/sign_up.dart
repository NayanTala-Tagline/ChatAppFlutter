import 'dart:developer' as developer;

import 'package:chat_app/core/authentication/otp_verification.dart';
import 'package:chat_app/middleware/InternetConnectionChecker.dart';
import 'package:chat_app/middleware/auth/sign_up.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/enums.dart';
import 'package:chat_app/ui/overlay/loading_overlay.dart';
import 'package:chat_app/ui/overlay/toast.dart';
import 'package:chat_app/ui/widget/account_picker.dart';
import 'package:chat_app/ui/widget/chat_field.dart';
import 'package:chat_app/ui/widget/date_formatting.dart';
import 'package:chat_app/ui/widget/form_validators.dart';
import 'package:chat_app/ui/widget/gender_identifier.dart';
import 'package:chat_app/ui/widget/primary_button.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _useridController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AccountButtonState _buttonState = AccountButtonState.disabled;

  static const Widget paddingfour = Padding(padding: EdgeInsets.all(4));
  static const Widget paddingsixteen = Padding(padding: EdgeInsets.all(16));
  DateTime? _dateOfBirth;
  Gender _gender = Gender.MALE;
  late SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff13999a),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xfff13999a),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(StringValue.create_account,
                  style: Theme.of(context).textTheme.headline6),
            ),
            paddingsixteen,
            Form(
              key: _formKey,
              onChanged: updateButtonState,
              child: Column(
                children: <Widget>[
                  AccountText(
                      icon: Icons.person_outline,
                      placeholderText: StringValue.username,
                      textController: _usernameController,
                      keyboardType: TextInputType.name,
                      validation: FormValidators.validateName),
                  paddingfour,
                  AccountText(
                    icon: Icons.email_outlined,
                    placeholderText: StringValue.email,
                    textController: _useridController,
                    keyboardType: TextInputType.emailAddress,
                    validation: FormValidators.validateEmail,
                  ),
                  paddingfour,
                  AccountText(
                      icon: Icons.lock_outline,
                      placeholderText: StringValue.password,
                      textController: _passwordController,
                      passwordField: true,
                      obscureText: true,
                      validation: FormValidators.validateNewPassword),
                  paddingfour,
                  AccountText(
                      icon: Icons.lock_outline,
                      placeholderText: StringValue.confirm_password,
                      textController: _passwordConfirmationController,
                      obscureText: true,
                      passwordField: true,
                      validation: FormValidators.validateNewPassword),
                  paddingfour,
                  AccountPicker(
                    icon: Icons.date_range_outlined,
                    text: _dateOfBirth?.dayMonthYearFormat ??
                        StringValue.dateofbirth,
                    dateTime: currentSystemDateTime(),
                    pickerMode: CupertinoDatePickerMode.date,
                    onChanged: _setDateOfBirth,
                  ),
                  paddingfour,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(StringValue.gender_identiy,
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            RadioButton(
                              title: StringValue.male,
                              value: Gender.MALE,
                              groupValue: _gender,
                              onValueChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                            ),
                            RadioButton(
                              title: StringValue.female,
                              value: Gender.FEMALE,
                              groupValue: _gender,
                              onValueChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            RadioButton(
                              title: StringValue.other,
                              value: Gender.OTHER,
                              groupValue: _gender,
                              onValueChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                            ),
                            RadioButton(
                              title: StringValue.unidentified,
                              value: Gender.UNIDENTIFIED,
                              groupValue: _gender,
                              onValueChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(8)),
            PrimaryButton(
              title: StringValue.create,
              buttonState: _buttonState,
              onTap: () async {
                bool isNetwork = await Network.isInternetAvailable();
                FocusScope.of(context).requestFocus(FocusNode());
                prefs = await SharedPreferences.getInstance();
                // confirm password
                if (_passwordController.text !=
                    _passwordConfirmationController.text) {
                  ToastModel.errorToast(msg: "Please confirm password");
                  return;
                }

                // Date of birth
                if (_dateOfBirth == null) {
                  ToastModel.errorToast(msg: "Please add birthdate");
                  return;
                }

                setState(() {
                  _buttonState = AccountButtonState.enabled;
                });
                if (isNetwork) {
                  ApiRepose apiRepose = await LoadingOverlay.of(context)
                      .during(SignUpApi.signUp(new SignUpBody(
                    userName: _usernameController.text,
                    email: _useridController.text,
                    dob: _dateOfBirth.toString(),
                    password: _passwordController.text,
                    gender: _gender == Gender.UNIDENTIFIED
                        ? null
                        : EnumToString.convertToString(_gender),
                    providerType:
                        EnumToString.convertToString(ProviderType.NORMAL),
                  )));

                  if (apiRepose.statusCode == 200 &&
                      apiRepose.data!.id! != null &&
                      apiRepose.data!.token! != null) {
                    await prefs.setString(
                        StringValue.userid, apiRepose.data!.id!);
                    await prefs.setString(
                        StringValue.accessToken, apiRepose.data!.token!);
                    ToastModel.successToast(msg: "${apiRepose.message}");
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return OtpVerification(email: _useridController.text);
                      },
                    ));
                  } else {
                    ToastModel.errorToast(msg: "${apiRepose.message}");
                  }
                  developer.log(apiRepose.message.toString());
                } else {
                  ToastModel.errorToast(
                      msg: StringValue.internetConnectionError);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setDateOfBirth(DateTime newDateTime) {
    setState(() {
      _dateOfBirth = newDateTime;
      updateButtonState();
    });
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
    _usernameController.dispose();
    _useridController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }
}
