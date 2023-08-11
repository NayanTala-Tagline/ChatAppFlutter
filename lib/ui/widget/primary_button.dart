import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton(
      {Key? key,
      required this.title,
      this.buttonState = AccountButtonState.enabled,
      required this.onTap})
      : super(key: key);

  final String title;
  final Function() onTap;
  final AccountButtonState buttonState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = buttonState == AccountButtonState.enabled
        ? [Color(0xff72E4E4), Color(0xff1AB2D2)]
        : [Color(0xff525d65), Color(0xff525d65)];
    return RaisedButton(
      onPressed: buttonState == AccountButtonState.enabled
          ? () async {
              onTap();
            }
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      padding: const EdgeInsets.all(0),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors),
        ),
        child: Align(
            alignment: Alignment.center,
            child: Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))),
      ),
    );
  }
}

enum AccountButtonState { enabled, disabled }
