import 'package:chat_app/ui/widget/string_value.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottom_date_picker.dart';
import 'date_formatting.dart';

class AccountPicker extends StatelessWidget {
  AccountPicker(
      {Key? key,
      required this.icon,
      required this.text,
      required this.dateTime,
      required this.pickerMode,
      required this.onChanged})
      : super(key: key);

  final IconData icon;
  final String text;
  final CupertinoDatePickerMode pickerMode;
  final DateTime dateTime;
  final Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: SizedBox(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Icon(icon),
              ),
              Container(
                child: Text(text,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xff8a8f96),
                    )),
              ),
            ]),
          ),
        ),
      ),
      onTap: () {
        /* var adjustedMaxtime = (pickerMode == CupertinoDatePickerMode.time)
            ? null
            : currentSystemDateTime();*/
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return Wrap(
              children: [
                _donePickerHeader(context),
                BottomDatePicker(
                  picker: CupertinoDatePicker(
                    mode: pickerMode,
                    initialDateTime: currentSystemDateTime(),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: onChanged,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _donePickerHeader(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(StringValue.done,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2DAFC4)))),
        ),
      ),
    );
  }
}
