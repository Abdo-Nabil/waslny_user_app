import 'package:dartz/dartz.dart';
import 'package:waslny_user/features/authentication/domain/entities/user_entity.dart';

import '../../../../core/error/failures.dart';

abstract class AuthRepo {
  //return verificationId in case in fireBase
  Future<Either<Failure, dynamic>> loginOrResendSms(String phoneNumber);
  Future<Either<Failure, dynamic>> verifySmsCode(String smsCode);
  Future<Either<Failure, Unit>> createUser(String userName);
  Future<Either<Failure, UserEntity>> getUserData(String userId);
  Either<Failure, String?> getToken();
  Future<Either<Failure, Unit>> setToken(String token);
}
