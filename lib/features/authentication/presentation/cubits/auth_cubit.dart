import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/features/authentication/domain/usecases/get_token_use_case.dart';
import 'package:waslny_user/features/authentication/domain/usecases/login_or_resend_sms_use_case.dart';
import 'package:waslny_user/features/authentication/domain/usecases/set_token_use_case.dart';
import 'package:waslny_user/features/authentication/domain/usecases/verify_sms_code_use_case.dart';
import 'package:waslny_user/resources/app_strings.dart';

import '../../../../core/error/failures.dart';
import '../../../../resources/constants_manager.dart';
import '../../domain/usecases/create_user_use_case.dart';
import '../../domain/usecases/get_user_data_use_case.dart';
import '../../domain/usecases/verify_sms_code_use_case.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final CreateUserUseCase createUserUseCase;
  final GetUserDataUseCase getUserDataUseCase;
  final LoginOrResendSmsUseCase loginOrResendSmsUseCase;
  final VerifySmsCodeUseCase verifySmsCodeUseCase;
  final GetTokenUseCase getTokenUseCase;
  final SetTokenUseCase setTokenUseCase;

  AuthCubit({
    required this.createUserUseCase,
    required this.getUserDataUseCase,
    required this.loginOrResendSmsUseCase,
    required this.verifySmsCodeUseCase,
    required this.getTokenUseCase,
    required this.setTokenUseCase,
  }) : super(AuthInitial());

  bool showLoginButton = false;
  bool showResendButton = false;

  static AuthCubit getIns(context) {
    return BlocProvider.of<AuthCubit>(context);
  }

  activeResendButton() {
    showResendButton = true;
    emit(ActiveResendButtonState());
  }

  bool isValidPhoneNumber(String value) {
    if (value.length == 10 &&
        (value.startsWith('10') ||
            value.startsWith('11') ||
            value.startsWith('12') ||
            value.startsWith('15'))) {
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

  String? validatePinCodeFields(BuildContext context, String value) {
    if (value.isEmpty) {
      return AppStrings.emptyValue.tr(context);
    } else if (value.length != ConstantsManager.pinCodesLength) {
      return AppStrings.enterAllDigits.tr(context);
    } else {
      return null;
    }
  }

  // String? validatePhoneNumberInRegisterMode(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return AppStrings.enterYourPhone;
  //   } else if (!isValidPhoneNumber(value)) {
  //     return AppStrings.enterValidPhone;
  //   }
  //   return null;
  // }

  String? validateUsername(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterYourName.tr(context);
    }
    return null;
  }

  Future listenForSms(BuildContext context, GlobalKey<FormState> formKey,
      TextEditingController otpController, mounted) async {
    try {
      otpController.text = (await AltSmsAutofill().listenForSms)!;
      if (!mounted) return;
      await AuthCubit.getIns(context)
          .verifySmsCode(otpController.text, formKey);
      debugPrint('code ${otpController.text}');
    } catch (e) {
      debugPrint('SMS Automatic fetching problem Problem :: $e');
      emit(SmsListeningException());
    }
  }

  ///----------------------------------------------------------\\\

  handleFailure(Failure failure) {
    if (failure.runtimeType == InternetConnectionFailure) {
      emit(EndLoadingStateWithError(AppStrings.internetConnectionError));
    } else if (failure.runtimeType == ServerFailure) {
      emit(EndLoadingStateWithError(AppStrings.someThingWentWrong));
    } else if (failure.runtimeType == InvalidSmsFailure) {
      emit(EndLoadingStateWithSmsError());
    }
  }

  Future loginOrResendSms(String phoneNumber) async {
    emit(StartLoadingState());
    debugPrint(phoneNumber);
    await Future.delayed(const Duration(seconds: 3));
    final result = await loginOrResendSmsUseCase(phoneNumber);
    result.fold(
      (failure) {
        handleFailure(failure);
      },
      (success) {
        showResendButton = false;
        emit(EndLoadingToOtpScreen());
      },
    );
  }

  Future saveToken(UserCredential userCredential) async {
    final token = await userCredential.user?.getIdToken();
    await setTokenUseCase.call(token!);
  }

  Future verifySmsCode(String smsCode, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      emit(StartLoadingState());
      final result = await verifySmsCodeUseCase(smsCode);
      result.fold(
        (failure) {
          handleFailure(failure);
        },
        (userCredential) async {
          //
          if (userCredential.additionalUserInfo.isNewUser) {
            await saveToken(userCredential);
            emit(EndLoadingToRegisterScreen());
          } else {
            // getUserData();
            emit(EndLoadingToHomeScreen());
          }
        },
      );
    }
  }

  //Create New User
  Future register(
    GlobalKey<FormState> formKey,
    TextEditingController username,
  ) async {
    if (formKey.currentState!.validate()) {
      emit(StartLoadingState());
      await Future.delayed(const Duration(seconds: 3));
      final result = await createUserUseCase.call(username.text);
      result.fold(
        (failure) {
          handleFailure(failure);
        },
        (success) async {
          emit(EndLoadingToHomeScreen());
        },
      );
    }
  }

  // Future getUserData(String userId) async {
  //     final result = await getUserDataUseCase.call(userId);
  //     result.fold(
  //       (failure) {
  //         handleFailure(failure);
  //       },
  //       (success) async {
  //         emit(EndLoadingToHomeScreen());
  //       },
  //     );
  //   }

}
