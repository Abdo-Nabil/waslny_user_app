import 'package:flutter/material.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';

class TextRow extends StatelessWidget {
  final String text;
  final String textButton;
  final Function onTap;
  const TextRow(
      {required this.text,
      required this.textButton,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text.tr(context)),
        TextButton(
          child: Text(
            textButton.tr(context),
          ),
          onPressed: () {
            onTap();
          },
        ),
      ],
    );
  }
}
