import 'package:bluetooth_ft/ui/widgets/app_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class AppLoaderDialog{

  static void showLoaderDialog(String? message){
    SmartDialog.showLoading(
      backDismiss: false,
      clickBgDismissTemp: false,
      isUseAnimationTemp: true,
      isLoadingTemp: true,
      widget: Center(
        child: AppLoader(message: message),
      )
    );
  }

  static void dismissLoaderDialog(){
    SmartDialog.dismiss();
  }
}