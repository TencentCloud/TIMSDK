import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType { success, fail, info }

class Toast {
  static FToast? fToast;
  static removeToast() {
    fToast?.removeCustomToast();
  }

  static removeAllQueuedToasts() {
    fToast?.removeQueuedCustomToasts();
  }

  static init(BuildContext context) {
    fToast = FToast();
    fToast!.init(context);
  }

  static IconData generateIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check;
      case ToastType.fail:
        return Icons.close;
      case ToastType.info:
        return Icons.info;
    }
  }

  static showToast(ToastType type, String msg, BuildContext context) {
    init(context);
    fToast!.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: const Color(0xFF333333),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 36.0),
                  child: Icon(generateIcon(type),
                      size: 64.0, color: Colors.white)),
              Text(
                msg,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        gravity: ToastGravity.CENTER,
        toastDuration: const Duration(seconds: 2));
  }
}
