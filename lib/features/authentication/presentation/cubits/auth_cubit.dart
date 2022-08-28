import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/resources/app_strings.dart';
import 'package:waslny_user/resources/constants_manager.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  bool showLoginButton = false;
  bool showResendButton = false;
  late String verificationIdentity;
  String? token;

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

  String? validatePhoneNumberInRegisterMode(String? value) {
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

  Future login(String phoneNumber) async {
    emit(StartLoadingState());
    await Future.delayed(const Duration(seconds: 3));
    await firebaseLoginWithPhone(phoneNumber);
    emit(EndLoadingStateAndNavigate());
  }

  Future resendSms(String phoneNumber) async {
    emit(StartLoadingState());
    await Future.delayed(const Duration(seconds: 3));
    await firebaseLoginWithPhone(phoneNumber);
    emit(ResendSmsState());
  }

  Future firebaseLoginWithPhone(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: AppStrings.countryCode + phoneNumber,
      timeout: const Duration(seconds: ConstantsManager.smsTimer),
      //
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          debugPrint('The provided phone number is not valid ::::');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Update the UI - wait for the user to enter the SMS code
        verificationIdentity = verificationId;
        debugPrint(
            'Code hase been sent to ${AppStrings.countryCode + phoneNumber}');
        debugPrint('resend token :: $resendToken');
      },
      //
      verificationCompleted: (PhoneAuthCredential credential) {
        debugPrint('Verification Completed ::  $credential');
      },
      //
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('Code Auto Retrieval Timeout :: $verificationId');
      },
    );
  }

  Future verifySmsCode(String smsCode) async {
    emit(StartLoadingState());
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationIdentity,
      smsCode: smsCode,
    );
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final bool? isNewUser = userCredential.additionalUserInfo?.isNewUser;

      // if(isNewUser!){
      //   createUserAccount(UserModel userModel);
      // }else{
      //
      // }
      final tokennn = await userCredential.user?.getIdToken();
      debugPrint('LLL 1 :::::: ${userCredential.user?.phoneNumber}');
      debugPrint('LLL 2 :::::: ${userCredential.user?.uid}');
      debugPrint('LLL 3 :::::: ${tokennn}');
      debugPrint(
          'LLL 4 :::::: ${userCredential.additionalUserInfo?.isNewUser}');
      // debugPrint('LLL 3 :::::: ${signedUser.user?.');
      // token = await FirebaseAuth.instance.currentUser?.getIdToken();
      //
      // check the user id if found go to home else go to register name screen
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // //TODO: save the token
      emit(EndLoadingStateAndNavigate());
    } catch (e) {
      debugPrint('Error in sign in :: $e');
      emit(EndLoadingStateWithSmsError());
    }
  }

  Future register(
    GlobalKey<FormState> formKey,
    TextEditingController username,
    TextEditingController phone,
  ) async {
    if (formKey.currentState!.validate()) {
      emit(StartLoadingState());
      // username.text.trim()
      //register code using firebase
      await Future.delayed(const Duration(seconds: 3));
      if (false) {
        emit(EndLoadingStateAndNavigate());
      } else {
        emit(EndLoadingStateWithError());
      }
      // debugPrint('Register Done');
    }
  }
}
