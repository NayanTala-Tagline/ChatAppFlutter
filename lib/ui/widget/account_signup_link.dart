import 'package:chat_app/ui/widget/string_value.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AccountSignupLink extends StatelessWidget {
  AccountSignupLink({Key? key, required this.onLinkTapped}) : super(key: key);

  final Function onLinkTapped;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: StringValue.need_accopunt,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xffffffff),
            ),
          ),
          TextSpan(
              text: StringValue.sign_up,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xffffffff),
                  decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  onLinkTapped();
                }),
        ],
      ),
    );
  }
}
