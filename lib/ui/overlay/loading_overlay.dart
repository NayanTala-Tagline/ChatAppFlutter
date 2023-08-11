import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingOverlay {
  BuildContext _context;

  void _show() {
    final spinner = const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff4EC8D3)));

    showDialog<void>(
        context: _context,
        barrierDismissible: false,
        useRootNavigator: true,
        useSafeArea: false,
        builder: (_) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Container(
              decoration:
                  const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.25)),
              child: Center(child: spinner),
            ),
          );
        });
  }

  void _hide() {
    Navigator.of(_context, rootNavigator: true).pop();
  }

  Future<T> during<T>(Future<T> future) {
    _show();
    return future.then((T value) {
      _hide();
      return Future.value(value);
    }).catchError((Object error, dynamic _) {
      _hide();
      return Future<T>.error(error);
    });
  }

  LoadingOverlay._create(this._context);

  factory LoadingOverlay.of(BuildContext context) {
    return LoadingOverlay._create(context);
  }
}
