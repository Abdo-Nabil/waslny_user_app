import 'package:flutter/material.dart';
import 'package:waslny_user/core/extensions/context_extension.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/widgets/add_vertical_space.dart';
import 'package:waslny_user/core/widgets/custom_form_field.dart';
import 'package:waslny_user/features/home_screen/presentation/widgets/rounded_widget.dart';
import 'package:waslny_user/resources/app_margins_paddings.dart';

import '../../../resources/app_strings.dart';
import '../../localization/presentation/cubits/localization_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglishLocale =
        LocalizationCubit.getIns(context).isEnglishLocale();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Colors.blueGrey,
            ),
            Positioned(
              left: isEnglishLocale ? AppPadding.p16 : null,
              right: isEnglishLocale ? null : AppPadding.p16,
              top: AppPadding.p38,
              child: RoundedWidget(
                iconData: Icons.menu,
                onTap: () {},
              ),
            ),
            Positioned(
              left: isEnglishLocale ? null : AppPadding.p16,
              right: isEnglishLocale ? AppPadding.p16 : null,
              top: AppPadding.p38,
              child: RoundedWidget(
                iconData: Icons.my_location,
                onTap: () {},
              ),
            ),
            Positioned(
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.p8),
                child: SizedBox(
                  height: context.height * 0.265,
                  width: context.width - AppPadding.p16,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomFormFiled(
                          context: context,
                          label: AppStrings.from,
                          icon: const Icon(Icons.add_location_alt_outlined),
                          controller: _fromController,
                          validate: (_) {},
                        ),
                        const AddVerticalSpace(AppPadding.p16),
                        CustomFormFiled(
                          context: context,
                          label: AppStrings.whereToGo,
                          icon: const Icon(Icons.add_location_alt_outlined),
                          controller: _toController,
                          validate: (_) {},
                        ),
                        const AddVerticalSpace(AppPadding.p16),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            AppStrings.requestCar.tr(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
