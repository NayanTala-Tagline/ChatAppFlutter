import 'dart:developer' as developer;

import 'package:chat_app/middleware/InternetConnectionChecker.dart';
import 'package:chat_app/middleware/auth/send_connection_request.dart';
import 'package:chat_app/model/auth_model.dart';
import 'package:chat_app/ui/overlay/loading_overlay.dart';
import 'package:chat_app/ui/overlay/toast.dart';
import 'package:chat_app/ui/widget/string_value.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: non_constant_identifier_names
Future<dynamic> ShowAlertDialog({
  required BuildContext context,
  required ShowAlertDialogBody body,
}) async {
  ApiRepose apiRepose;
  Widget okButton = FlatButton(
    child: Text(body.acceptRejectstatus!),
    onPressed: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userid = prefs.getString(StringValue.userid);
      bool isNetwork = await Network.isInternetAvailable();
      if (isNetwork) {
        apiRepose = await LoadingOverlay.of(context).during(
            SendConnectionRequest.sendConnectionRequest(SendConnectionsBody(
                userId: userid!,
                connectionId: body.connectionId!,
                status: body.status!)));
        if (apiRepose.statusCode == 200) {
          ToastModel.successToast(msg: "${apiRepose.message}");
          developer.log(apiRepose.message.toString());
        } else {
          ToastModel.errorToast(msg: "${apiRepose.message}");
        }
      } else {
        ToastModel.errorToast(msg: StringValue.internetConnectionError);
      }
      body.onRefresh!();
      Navigator.pop(context);
    },
  );
  Widget exitButton = FlatButton(
    child: Text(StringValue.cancel),
    onPressed: () async {
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(StringValue.alert),
    content: Text(body.alertMessag!),
    actions: [
      okButton,
      exitButton,
    ],
  );
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class ShowAlertDialogBody {
  String? connectionId;
  String? status;
  String? acceptRejectstatus;
  String? alertMessag;
  Function? onRefresh;

  ShowAlertDialogBody({
    required this.connectionId,
    required this.status,
    required this.acceptRejectstatus,
    required this.alertMessag,
    required this.onRefresh,
  });
}
