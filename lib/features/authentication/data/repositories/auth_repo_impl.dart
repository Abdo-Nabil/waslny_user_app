import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:waslny_user/core/error/failures.dart';
import 'package:waslny_user/core/network/network_info.dart';
import 'package:waslny_user/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:waslny_user/features/authentication/data/models/user_model.dart';

import 'package:waslny_user/features/authentication/domain/entities/user_entity.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/auth_repo.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthLocalDataSource authLocalDataSource;
  final AuthRemoteDataSource authRemoteDataSource;
  final NetworkInfo networkInfo;
  AuthRepoImpl({
    required this.authLocalDataSource,
    required this.authRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> getUserData(String userId) {
    // TODO: implement getUserData
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, dynamic>> loginOrResendSms(String phoneNumber) async {
    final bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      //
      try {
        await authRemoteDataSource.loginOrResendSms(phoneNumber);
        return const Right(unit);
      } on ServerException {
        return Left(ServerFailure());
      }
      //
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> createUser(UserEntity userEntity) async {
    final bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      //
      try {
        final UserModel useModel = UserModel(
          userId: userEntity.userId,
          phoneNumber: userEntity.phoneNumber,
          name: userEntity.name,
        );
        await authRemoteDataSource.createUser(useModel);
        return Future.value(const Right(unit));
      } on ServerException {
        return Left(ServerFailure());
      }
      //
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, dynamic>> verifySmsCode(String smsCode) async {
    final bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      //
      try {
        final UserCredential userCredential =
            await authRemoteDataSource.verifySmsCode(smsCode);
        return Right(userCredential);
      } on InvalidSmsException {
        return Left(InvalidSmsFailure());
      } on ServerException {
        return Left(ServerFailure());
      }
      //
    } else {
      return Left(InternetConnectionFailure());
    }
  }

  @override
  Either<Failure, String?> getToken() {
    final String? result = authLocalDataSource.getToken();
    return Right(result);
  }

  @override
  Future<Either<Failure, Unit>> setToken(String token) async {
    try {
      await authLocalDataSource.setToken(token);
      return Future.value(const Right(unit));
    } on CacheSavingException {
      return Left(CacheSavingFailure());
    }
  }
}
