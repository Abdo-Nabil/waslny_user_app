import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waslny_user/core/widgets/add_vertical_space.dart';
import 'package:waslny_user/core/widgets/custom_form_field.dart';
import 'package:waslny_user/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:waslny_user/features/authentication/presentation/register_screen.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/button.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/image_with_logo.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/login_or_register_text.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/text_row.dart';
import 'package:waslny_user/features/localization/presentation/cubits/localization_cubit.dart';
import 'package:waslny_user/resources/app_strings.dart';
import 'package:waslny_user/resources/app_margins_paddings.dart';

import '../../../core/util/hex_color.dart';
import '../../../core/util/no_animation_page_route.dart';
import '../../../resources/colors_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
              const LoginOrRegisterText(AppStrings.loginAsAUser),
              const AddVerticalSpace(AppPadding.p20),
              Padding(
                padding: const EdgeInsets.all(AppPadding.p16),
                child: Form(
                  key: _formKey,
                  child: CustomFormFiled(
                    context: context,
                    controller: _phoneController,
                    label: AppStrings.phoneNumber,
                    icon: Icon(
                      LocalizationCubit.ins(context).isEnglishLocale()
                          ? Icons.phone
                          : Icons.phone_enabled,
                    ),
                    isNumberKeyboard: true,
                    onChange: (value) {
                      AuthCubit.getIns(context).phoneNumberValidator(value);
                    },
                  ),
                ),
              ),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return Button(
                    text: AppStrings.login,
                    showButton: AuthCubit.getIns(context).showLoginButton,
                    onTap: () {},
                  );
                },
              ),
              TextRow(
                text: AppStrings.dontHaveAccount,
                textButton: AppStrings.registerNow,
                onTap: () {
                  Navigator.of(context).push(
                    NoAnimationPageRoute(
                      builder: (context) {
                        return const RegisterScreen();
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
