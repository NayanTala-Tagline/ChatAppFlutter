import 'dart:developer' as developer;
import 'dart:io';

import 'package:chat_app/core/authentication/sign_up.dart';
import 'package:chat_app/core/chat/chat_screen.dart';
import 'package:chat_app/middleware/InternetConnectionChecker.dart';
import 'package:chat_app/middleware/SocialMediaLoginProvider.dart';
import 'package:chat_app/middleware/auth/sign_in.dart';
import 'package:chat_app/middleware/auth/sign_up.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/enums.dart';
import 'package:chat_app/ui/overlay/loading_overlay.dart';
import 'package:chat_app/ui/overlay/toast.dart';
import 'package:chat_app/ui/widget/account_signup_link.dart';
import 'package:chat_app/ui/widget/chat_field.dart';
import 'package:chat_app/ui/widget/form_validators.dart';
import 'package:chat_app/ui/widget/primary_button.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _useridController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
              Padding(padding: EdgeInsets.only(top: 16)),
              Text(
                StringValue.login_text,
                style: Theme.of(context).textTheme.headline6,
              ),
              Padding(padding: EdgeInsets.only(top: 24)),
              Form(
                key: _formKey,
                onChanged: updateButtonState,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AccountText(
                      icon: Icons.email_outlined,
                      placeholderText: StringValue.email,
                      textController: _useridController,
                      keyboardType: TextInputType.emailAddress,
                      validation: FormValidators.validateEmail,
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    AccountText(
                        icon: Icons.lock_outline,
                        placeholderText: StringValue.password,
                        textController: _passwordController,
                        obscureText: true,
                        passwordField: true,
                        validation: FormValidators.validatePassword),
                    Padding(padding: EdgeInsets.all(4)),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(32)),
              PrimaryButton(
                  title: StringValue.log_in,
                  buttonState: _buttonState,
                  onTap: () async {
                    try {
                      FocusScope.of(context).requestFocus(FocusNode());
                      prefs = await SharedPreferences.getInstance();

                      bool isNetwork = await Network.isInternetAvailable();
                      if (isNetwork) {
                        ApiRepose apiRepose =
                            await LoadingOverlay.of(context).during(
                          SignInApi.signIn(
                            email: _useridController.text,
                            password: _passwordController.text,
                          ),
                        );

                        if (apiRepose.statusCode == 200 &&
                            apiRepose.data!.id != null &&
                            apiRepose.data!.token != null) {
                          await prefs.setString(
                              StringValue.userid, apiRepose.data!.id!);
                          await prefs.setString(
                              StringValue.accessToken, apiRepose.data!.token!);
                          await prefs.setBool('login', true);
                          ToastModel.successToast(msg: "${apiRepose.message}");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChatScreen(userId: apiRepose.data!.id!)),
                          );
                        } else {
                          ToastModel.errorToast(msg: "${apiRepose.message}");
                        }
                      } else {
                        ToastModel.errorToast(
                            msg: StringValue.internetConnectionError);
                      }
                    } catch (e) {
                      developer.log(e.toString());
                    }
                  }),
              Padding(padding: EdgeInsets.all(8)),
              AccountSignupLink(onLinkTapped: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignUp()));
              }),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: socialMediaIcon(context: context),
              )
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
    _useridController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget socialMediaIcon({required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Platform.isIOS
            ? getSocialMediaContainer(
                image: StringValue.appleLogoSvg,
                loginWithOption: ProviderType.APPLE,
                context: context)
            : Container(),
        getSocialMediaContainer(
            image: StringValue.facebookLogoSvg,
            loginWithOption: ProviderType.FB,
            context: context),
        getSocialMediaContainer(
            image: StringValue.googleLogoSvg,
            loginWithOption: ProviderType.GOOGLE,
            context: context)
      ],
    );
    // );
  }
}

Widget getSocialMediaContainer({
  required BuildContext context,
  required String image,
  required ProviderType loginWithOption,
}) {
  SocialMediaLogin _mediaLogin =
      Provider.of<SocialMediaLogin>(context, listen: false);

  void apiCallingForSignUp({
    String? userName,
    String? email,
    required ProviderType providerType,
    required String token,
  }) async {
    bool isNetwork = await Network.isInternetAvailable();
    if (isNetwork) {
      ApiRepose apiRepose = await LoadingOverlay.of(context).during(
          SignUpApi.signUp(new SignUpBody(
              userName: userName,
              email: email,
              providerType: EnumToString.convertToString(providerType),
              socialInfo: token)));
      if (apiRepose.statusCode == 200 &&
          apiRepose.data!.id! != null &&
          apiRepose.data!.token! != null) {
        ToastModel.successToast(msg: "${apiRepose.message}");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(StringValue.userid, apiRepose.data!.id!);
        await prefs.setString(StringValue.accessToken, apiRepose.data!.token!);
        await prefs.setBool('login', true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatScreen()));
      } else {
        ToastModel.errorToast(msg: "${apiRepose.message}");
      }
      developer.log(apiRepose.message.toString());
    } else {
      ToastModel.errorToast(msg: StringValue.internetConnectionError);
    }
  }

  return GestureDetector(
    child: Stack(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
          child: SvgPicture.asset(
            '$image',
            fit: BoxFit.fitHeight,
          ),
        ),
        loginWithOption == ProviderType.APPLE
            ? Container(
                margin: EdgeInsets.all(10),
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 6.0, color: Colors.black)),
              )
            : Container()
      ],
    ),
    onTap: () async {
      if (loginWithOption == ProviderType.APPLE) {
        await _mediaLogin.signInWithApple().then((result) {
          if (result != null) {
            developer.log(_mediaLogin.appleToken.toString());
            apiCallingForSignUp(
                userName: _mediaLogin.appleUserName,
                providerType: ProviderType.APPLE,
                email: _mediaLogin.appleUserEmail,
                token: _mediaLogin.appleToken!);
          }
        });
      } else if (loginWithOption == ProviderType.FB) {
        await _mediaLogin.facebookLogin().then((result) {
          if (result != null) {
            apiCallingForSignUp(
                token: _mediaLogin.getFacebookToken,
                userName: _mediaLogin.facebookName,
                providerType: ProviderType.FB,
                email: _mediaLogin.facebookEmail);
          }
        });
      } else if (loginWithOption == ProviderType.GOOGLE) {
        await _mediaLogin.signInWithGoogle().then((result) async {
          if (result != null) {
            apiCallingForSignUp(
                token: _mediaLogin.getGoogleToken,
                userName: _mediaLogin.googleName,
                providerType: ProviderType.GOOGLE,
                email: _mediaLogin.googleEmail);
          }
        });
      }
    },
  );
}
