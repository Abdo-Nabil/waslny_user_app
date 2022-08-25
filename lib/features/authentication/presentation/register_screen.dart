import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waslny_user/config/routes/app_routes.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/button.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/image_with_logo.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/login_or_register_text.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/text_row.dart';
import 'package:waslny_user/features/on_boarding/on_boarding_screen.dart';

import '../../../core/util/no_animation_page_route.dart';
import '../../../core/widgets/add_vertical_space.dart';
import '../../../core/widgets/custom_form_field.dart';
import '../../../resources/app_strings.dart';
import '../../../resources/colors_manager.dart';
import '../../../resources/app_margins_paddings.dart';
import '../../localization/presentation/cubits/localization_cubit.dart';
import 'cubits/auth_cubit.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  //
  @override
  Widget build(BuildContext context) {
    //
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: ColorsManager.greyBlack,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ImageWithLogo(),
              const LoginOrRegisterText(AppStrings.registerANewUser),
              const AddVerticalSpace(AppPadding.p20),
              Padding(
                padding: const EdgeInsets.all(AppPadding.p16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomFormFiled(
                        context: context,
                        controller: _nameController,
                        label: AppStrings.username,
                        icon: const Icon(
                          Icons.person,
                        ),
                        validate: (value) {
                          return AuthCubit.getIns(context)
                              .validateUsername(value)
                              ?.tr(context);
                        },
                      ),
                      const AddVerticalSpace(AppPadding.p16),
                      CustomFormFiled(
                        context: context,
                        controller: _phoneController,
                        label: AppStrings.phoneNumber,
                        icon: Icon(
                          LocalizationCubit.ins(context).isEnglishLocale()
                              ? Icons.phone
                              : Icons.phone_enabled,
                        ),
                        isNumberKeyboard: true,
                        validate: (value) {
                          return AuthCubit.getIns(context)
                              .validateRegisterPhoneNumber(value)
                              ?.tr(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return Button(
                    text: AppStrings.register,
                    onTap: () async {
                      await AuthCubit.getIns(context).register(
                        _formKey,
                        _nameController,
                        _phoneController,
                      );
                    },
                  );
                },
              ),
              TextRow(
                text: AppStrings.alreadyHaveAccount,
                textButton: AppStrings.loginNow,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    NoAnimationPageRoute(
                      builder: (context) {
                        return const LoginScreen();
                      },
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
