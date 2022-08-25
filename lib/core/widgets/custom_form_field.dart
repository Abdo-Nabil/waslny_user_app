import 'package:flutter/material.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';

import '../../features/authentication/presentation/cubits/auth_cubit.dart';
import '../../resources/colors_manager.dart';

class CustomFormFiled extends StatelessWidget {
  final BuildContext context;
  final String label;
  final Icon icon;
  final TextEditingController controller;
  final Function? onChange;
  final Function? validate;
  final bool isNumberKeyboard;

  const CustomFormFiled({
    required this.context,
    required this.label,
    required this.icon,
    required this.controller,
    this.onChange,
    this.validate,
    this.isNumberKeyboard = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumberKeyboard ? TextInputType.phone : null,
      style: const TextStyle(color: ColorsManager.whiteColor),
      decoration: InputDecoration(
        labelText: label.tr(context),
        prefixIcon: icon,
      ),
      onChanged: (value) {
        if (onChange != null) {
          onChange!(value);
        }
      },
      validator: (value) {
        if (validate != null) {
          return validate!(value);
        } else {
          return null;
        }
      },

      // decoration: ,
    );
  }
}
