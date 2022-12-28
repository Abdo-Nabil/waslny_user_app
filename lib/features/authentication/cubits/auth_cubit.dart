import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/features/authentication/services/models/user_model.dart';
import 'package:waslny_user/features/general/services/general_repo.dart';
import 'package:waslny_user/resources/app_strings.dart';

import '../../../../core/error/failures.dart';
import '../../../../resources/constants_manager.dart';
import '../services/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  final GeneralRepo generalRepo;

  AuthCubit({
    required this.authRepo,
    required this.generalRepo,
  }) : super(AuthInitial());

  bool showLoginButton = false;
  bool showResendButton = false;
  //
  late final UserCredential userCred;
  late final UserModel userData;

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
    if (failure.runtimeType == OfflineFailure) {
      emit(EndLoadingStateWithError(AppStrings.internetConnectionError));
    } else if (failure.runtimeType == ServerFailure) {
      emit(EndLoadingStateWithError(AppStrings.someThingWentWrong));
    } else if (failure.runtimeType == InvalidSmsFailure) {
      emit(EndLoadingStateWithSmsError());
    } else if (failure.runtimeType == CacheSavingFailure) {
      emit(EndLoadingStateWithError(AppStrings.savingTokenError));
    }
  }

  Future loginOrResendSms(String phoneNumber) async {
    emit(StartLoadingState());
    debugPrint(phoneNumber);
    await Future.delayed(const Duration(seconds: 3));
    final result = await authRepo.loginOrResendSms(phoneNumber);
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

  Future verifySmsCode(String smsCode, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      emit(StartLoadingState());
      final result = await authRepo.verifySmsCode(smsCode);
      result.fold(
        (failure) {
          handleFailure(failure);
        },
        (userCredential) async {
          //
          userCred = userCredential;
          await generalRepo.setString(AppStrings.storedId, userCred.user!.uid);
          //
          if (userCredential.additionalUserInfo!.isNewUser) {
            emit(EndLoadingToRegisterScreen());
          } else {
            await _afterBeingLogged();
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
      //come here
      final result = await authRepo.createUser(username.text);
      result.fold(
        (failure) {
          handleFailure(failure);
        },
        (success) async {
          await _afterBeingLogged();
        },
      );
    }
  }

  _afterBeingLogged() async {
    final isSaved1 = await _saveToken();
    final isSaved2 = await _saveFcmToken();

    if (isSaved1 && isSaved2) {
      emit(EndLoadingToHomeScreen());
    } else {
      emit(EndLoadingStateWithError(AppStrings.someThingWentWrong));
    }
  }

  Future<bool> _saveToken() async {
    final token = await userCred.user?.getIdToken();
    if (token != null) {
      final either = await generalRepo.setString(AppStrings.storedToken, token);
      return either.fold((failure) {
        handleFailure(failure);
        return false;
      }, (success) {
        return true;
      });
    } else {
      debugPrint('The token is nullllllllllll!');
      return false;
    }
  }

  Future<bool> _saveFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM token !!!!!!  $fcmToken');
    if (fcmToken != null) {
      await generalRepo.setString(AppStrings.fcmToken, fcmToken);
      return true;
    } else {
      return false;
    }
    // generalRepo.
  }

  Future getUserData() async {
    final result = await authRepo.getUserData();
    result.fold(
      (failure) {
        // handleFailure(failure);
      },
      (success) async {
        userData = success;
      },
    );
  }
}
