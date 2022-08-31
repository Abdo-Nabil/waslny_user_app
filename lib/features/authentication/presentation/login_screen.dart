import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/widgets/add_vertical_space.dart';
import 'package:waslny_user/core/widgets/custom_form_field.dart';
import 'package:waslny_user/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/button.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/image_with_logo.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/login_or_register_text.dart';
import 'package:waslny_user/features/localization/presentation/cubits/localization_cubit.dart';
import 'package:waslny_user/resources/app_strings.dart';
import 'package:waslny_user/resources/app_margins_paddings.dart';

import '../../../core/util/dialog_helper.dart';
import '../../../resources/colors_manager.dart';
import 'otp_screen.dart';

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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is StartLoadingState) {
          DialogHelper.loadingDialog(context);
        }
        //
        else if (state is EndLoadingToOtpScreen) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) {
              return OtpScreen(
                phoneNumber: _phoneController.text,
              );
            }),
          );
        }
        //
        else if (state is EndLoadingStateWithError) {
          Navigator.of(context).pop();
          DialogHelper.messageDialog(context, state.msg.tr(context));
        }
      },
      child: GestureDetector(
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
                      showPlus20: true,
                      icon: Icon(
                        LocalizationCubit.getIns(context).isEnglishLocale()
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
                      text: AppStrings.login.tr(context),
                      showButton: AuthCubit.getIns(context).showLoginButton,
                      onTap: () async {
                        AuthCubit.getIns(context)
                            .loginOrResendSms(_phoneController.text);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
