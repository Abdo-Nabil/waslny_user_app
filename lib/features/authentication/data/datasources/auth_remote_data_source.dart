import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:waslny_user/core/error/exceptions.dart';
import 'package:waslny_user/features/authentication/data/models/user_model.dart';

import '../../../../resources/app_strings.dart';
import '../../../../resources/constants_manager.dart';

abstract class AuthRemoteDataSource {
  Future<dynamic> loginOrResendSms(String phoneNumber);
  Future<dynamic> verifySmsCode(String smsCode);
  Future<Unit> createUser(String userName);
  Future<UserModel> getUserData(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  String? verificationIdentity;
  late String phone;
  late String userId;

  //

  @override
  Future<dynamic> loginOrResendSms(String phoneNumber) async {
    String temp = AppStrings.countryCode + phoneNumber;
    phone = temp;
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: temp,
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
      userId = userCredential.user!.uid;

      return userCredential;
    } catch (e) {
      debugPrint('verifySmsCode InvalidSmsException:: $e');
      throw InvalidSmsException();
    }
  }

  @override
  Future<Unit> createUser(String username) async {
    final db = FirebaseFirestore.instance;
    final UserModel userModel = UserModel(
      userId: userId,
      phoneNumber: phone,
      name: username,
    );
    try {
      await db.collection(AppStrings.usersCollection).add(userModel.toJson());

      return Future.value(unit);
    } catch (e) {
      debugPrint('Create user Exception :: $e');
      throw ServerException();
    }
  }

  @override
  Future<UserModel> getUserData(String userId) async {
    final db = FirebaseFirestore.instance;
    try {
      final jsonData = await db.collection(AppStrings.usersCollection).get();
      for (var doc in jsonData.docs) {
        final UserModel user = UserModel.fromJson(doc.data());
        if (user.userId == userId) {
          return user;
        }
      }
      debugPrint('User Not Found!');
      throw ServerException();
    } catch (e) {
      debugPrint('Get user Exception :: $e');
      throw ServerException();
    }
  }
}

//
//
// debugPrint('donnnnnnnnnnnnnnnne');
// await Future.delayed(Duration(seconds: 3));
//
// //ToDo Remove if NO NEED
// final temp = await getUserData(userId);
// debugPrint(temp.name);
//
