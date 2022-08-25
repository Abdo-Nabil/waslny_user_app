import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/features/authentication/presentation/cubits/auth_cubit.dart';

import '../../../../resources/app_margins_paddings.dart';

class Button extends StatelessWidget {
  final String text;
  final bool showButton;
  final Function onTap;

  const Button(
      {required this.text,
      this.showButton = true,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.p16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: showButton
              ? () {
                  onTap();
                }
              : null,
          child: Text(text.tr(context)),
        ),
      ),
    );
  }
}
