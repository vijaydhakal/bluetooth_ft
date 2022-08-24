import 'package:flutter/cupertino.dart';
import 'package:bluetooth_ft/core/constants/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoader extends StatelessWidget{

  final String? message;

  const AppLoader({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      right: true,
      left: true,
      child: Center(
        child: Column(
          children: <Widget>[
             const Icon(Icons.refresh_outlined),
            const SizedBox(height: 10,),
            Text(message != null && message!.isNotEmpty ? message! : '', style: AppStyle.textBody3,)
          ],
        ),
      )
    );
  }

}