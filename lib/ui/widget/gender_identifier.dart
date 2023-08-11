import 'package:chat_app/ui/overlay/enums.dart';
import 'package:flutter/material.dart';

class RadioButton extends StatelessWidget {
  RadioButton({
    Key? key,
    required this.title,
    required this.value,
    required this.onValueChanged,
    required this.groupValue,
  }) : super(key: key);

  final String title;
  final Gender value;
  final void Function(Gender?) onValueChanged;
  final Gender groupValue;

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      activeColor: Colors.white,
      value: value,
      groupValue: groupValue,
      onChanged: onValueChanged,
    );
  }
}
