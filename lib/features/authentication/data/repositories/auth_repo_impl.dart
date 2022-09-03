import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:waslny_user/core/error/failures.dart';
import 'package:waslny_user/core/network/network_info.dart';
import 'package:waslny_user/features/authentication/data/datasources/auth_local_data_source.dart';

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
  Future<Either<Failure, Unit>> createUser(String userName) async {
    final bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      //
      try {
        await authRemoteDataSource.createUser(userName);
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
  Future<Either<Failure, UserEntity>> getUserData(String userId) async {
    final bool isConnected = await networkInfo.isConnected;
    if (isConnected) {
      //
      try {
        final UserEntity userEntity =
            await authRemoteDataSource.getUserData(userId);
        return Right(userEntity);
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
