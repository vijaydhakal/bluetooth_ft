import 'package:flutter/material.dart';
import 'package:bluetooth_ft/core/constants/colors/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppAlert{

  static Future<void> showBottomToast({required String message}) async {
    await Fluttertoast.showToast(
        msg: message.isNotEmpty ? message : '',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.toastBackground,
        textColor: Colors.black87,
        fontSize: 14.0
    );
  }

  static Future<void> closeBottomToast() async {
    await Fluttertoast.cancel();
  }

}