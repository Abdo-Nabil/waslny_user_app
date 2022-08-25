import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/resources/app_strings.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  bool showLoginButton = false;

  static AuthCubit getIns(context) {
    return BlocProvider.of<AuthCubit>(context);
  }

  bool isValidPhoneNumber(String value) {
    if (value.length == 11 &&
        (value.startsWith('010') ||
            value.startsWith('011') ||
            value.startsWith('012') ||
            value.startsWith('015'))) {
      return true;
    }
    return false;
  }

  phoneNumberValidator(String value) {
    if (isValidPhoneNumber(value)) {
      showLoginButton = true;
      emit(ButtonStateEnabled());
    } else {
      showLoginButton = false;
      emit(ButtonStateDisabled());
    }
  }

  String? validateRegisterPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterYourPhone;
    } else if (!isValidPhoneNumber(value)) {
      return AppStrings.enterValidPhone;
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterYourName;
    }
    return null;
  }

  Future register(
    GlobalKey<FormState> formKey,
    TextEditingController username,
    TextEditingController phone,
  ) async {
    if (formKey.currentState!.validate()) {
      // username.text.trim()
      //register code using firebase
      // await Future.delayed(const Duration(seconds: 2));
      // debugPrint('Register Done');
    }
  }
}
