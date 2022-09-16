import 'package:flutter/material.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/widgets/add_horizontal_space.dart';
import 'package:waslny_user/resources/app_margins_paddings.dart';

import '../../features/localization/presentation/cubits/localization_cubit.dart';
import '../../resources/app_strings.dart';
import '../../resources/colors_manager.dart';
import '../../resources/styles_manager.dart';

class CustomFormFiled extends StatelessWidget {
  final BuildContext context;
  final String label;
  final Widget iconWidget;
  final TextEditingController controller;
  final Function? onChange;
  final Function? validate;
  final Function? onTap;
  final Function? onFieldSubmitted;
  final bool isNumberKeyboard;
  final bool showPlus20;
  final bool readOnly;
  final bool autoFocus;

  const CustomFormFiled({
    required this.context,
    required this.label,
    required this.iconWidget,
    required this.controller,
    this.onChange,
    this.validate,
    this.onTap,
    this.onFieldSubmitted,
    this.isNumberKeyboard = false,
    this.showPlus20 = false,
    this.readOnly = false,
    this.autoFocus = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnglishLocale =
        LocalizationCubit.getIns(context).isEnglishLocale();
    return TextFormField(
      controller: controller,
      keyboardType: isNumberKeyboard ? TextInputType.phone : null,
      readOnly: readOnly,
      autofocus: autoFocus,
      style: const TextStyle(color: ColorsManager.whiteColor),
      decoration: InputDecoration(
        labelText: label.tr(context),
        suffixIcon: isEnglishLocale
            ? null
            : showPlus20
                ? const ArabicSuffix()
                : null,
        prefixIcon: !showPlus20
            ? iconWidget
            : isEnglishLocale
                ? EnglishPrefix(
                    iconWidget: iconWidget,
                  )
                : iconWidget,
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
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      onFieldSubmitted: (value) {
        if (onFieldSubmitted != null) {
          onFieldSubmitted!(value);
        }
      },

      // decoration: ,
    );
  }
}

class EnglishPrefix extends StatelessWidget {
  const EnglishPrefix({
    Key? key,
    required this.iconWidget,
  }) : super(key: key);
  final Widget iconWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppPadding.p16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const AddHorizontalSpace(AppPadding.p14),
          Padding(
            padding: const EdgeInsets.only(right: AppPadding.p16),
            child: Text(
              AppStrings.plus20English,
              style: plus20textStyle(context),
            ),
          )
        ],
      ),
    );
  }
}

class ArabicSuffix extends StatelessWidget {
  const ArabicSuffix({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppPadding.p16),
          child: Text(
            AppStrings.plus20Arabic,
            style: plus20textStyle(context),
          ),
        ),
      ],
    );
  }
}
