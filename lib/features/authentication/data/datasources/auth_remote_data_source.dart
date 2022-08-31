import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:waslny_user/core/error/exceptions.dart';

import '../../../../resources/app_strings.dart';
import '../../../../resources/constants_manager.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<dynamic> loginOrResendSms(String phoneNumber);
  Future<Unit> createUser(UserModel userModel);
  Future<dynamic> verifySmsCode(String smsCode);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  String? verificationIdentity;
  @override
  Future<dynamic> loginOrResendSms(String phoneNumber) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: AppStrings.countryCode + phoneNumber,
        timeout: const Duration(seconds: ConstantsManager.smsTimer),
        //
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid ::::');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
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
    } catch (e) {
      debugPrint('loginOrResendSms ServerException:: $e');
      throw ServerException();
    }
  }

  @override
  Future<Unit> createUser(UserModel userModel) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<dynamic> verifySmsCode(String smsCode) async {
    PhoneAuthCredential credential;
    if (verificationIdentity == null) {
      throw ServerException();
    } else {
      credential = PhoneAuthProvider.credential(
        verificationId: verificationIdentity!,
        smsCode: smsCode,
      );
    }
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      debugPrint('verifySmsCode InvalidSmsException:: $e');
      throw InvalidSmsException();
    }
  }
}
