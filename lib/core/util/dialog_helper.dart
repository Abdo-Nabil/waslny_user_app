import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/widgets/add_vertical_space.dart';
import 'package:waslny_user/resources/app_margins_paddings.dart';

import '../../features/authentication/presentation/widgets/timer_widget.dart';
import '../../resources/app_strings.dart';
import '../../resources/constants_manager.dart';

class DialogHelper {
  static Future loadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(AppStrings.loading.tr(context)),
              const CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  static Future waitingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const AddVerticalSpace(AppPadding.p16),
              Text(AppStrings.waiting.tr(context)),
            ],
          ),
        );
      },
    );
  }

  static Future messageDialog(BuildContext context, String msg) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.alert.tr(context)),
          content: Text(msg),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppStrings.ok.tr(context)))
          ],
        );
      },
    );
  }

  static Future messageDialogWithDoublePop(BuildContext context, String msg) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.alert.tr(context)),
          content: Text(msg),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(AppStrings.ok.tr(context)))
          ],
        );
      },
    );
  }

  static Future messageWithActionDialog(
      BuildContext context, String msg, Function onOkButton) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.alert.tr(context)),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await onOkButton();
              },
              child: Text(
                AppStrings.ok.tr(context),
              ),
            )
          ],
        );
      },
    );
  }
}
