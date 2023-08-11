import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountText extends StatelessWidget {
  AccountText({
    Key? key,
    required this.icon,
    required this.placeholderText,
    required this.textController,
    this.keyboardType,
    required this.validation,
    this.obscureText = false,
    this.onChanged,
    this.passwordField = false,
    this.otpVerification = false,
  }) : super(key: key);

  final IconData icon;
  final String placeholderText;
  final TextEditingController textController;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String) validation;
  final Function(String)? onChanged;
  final bool passwordField;
  final bool otpVerification;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(right: 8),
                child: TextFormField(
                    inputFormatters: otpVerification
                        ? [LengthLimitingTextInputFormatter(4)]
                        : [],
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: textController,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: placeholderText,
                        errorStyle: const TextStyle(fontSize: 0, height: 0)),
                    validator: (value) {
                      if (validation != null) {
                        return validation(value!);
                      } else {
                        return null;
                      }
                    }),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
