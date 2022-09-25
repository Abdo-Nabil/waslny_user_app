import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waslny_user/core/error/exceptions.dart';
import 'package:waslny_user/core/error/failures.dart';
import 'package:waslny_user/features/home_screen/services/direction_model.dart';
import 'package:waslny_user/features/home_screen/services/place_model.dart';
import 'package:waslny_user/features/home_screen/services/home_remote_data.dart';

import 'home_local_data.dart';

class HomeRepo {
  final HomeRemoteData homeRemoteData;
  final HomeLocalData homeLocalData;
  HomeRepo(this.homeRemoteData, this.homeLocalData);

  //-----------------Local data source-----------------

  Future<Either<Failure, LocPermission>> checkLocationPermissions() async {
    try {
      final locPermission = await homeLocalData.checkLocationPermissions();
      return Right(locPermission);
    } on LocationPermissionException {
      return Left(LocationPermissionFailure());
    }
  }

  Future<Either<Failure, LatLng>> getMyLocation() async {
    try {
      final latLng = await homeLocalData.getMyLocation();
      return Right(latLng);
    } on TimeLimitException {
      return Left(TimeLimitFailure());
    } on LocationDisabledException {
      return Left(LocationDisabledFailure());
    }
  }

  Either<Failure, Stream<LatLng>> getMyLocationStream() {
    try {
      final latLngStream = homeLocalData.getMyLocationStream();
      return Right(latLngStream);
    } on TimeLimitException {
      return Left(TimeLimitFailure());
    } on LocationDisabledException {
      return Left(LocationDisabledFailure());
    }
  }

  //
  //
  //-----------------Remote data source-----------------

  Future<bool> isConnected() async {
    return await homeRemoteData.isConnected();
  }

  Future<Either<Failure, List<PlaceModel>>> searchForPlace(
      String value, bool isEnglish) async {
    try {
      final result = await homeRemoteData.searchForPlace(value, isEnglish);
      return Right(result);
    } on ServerException {
      debugPrint('Home Repo :: searchForPlace :: ServerException :: ');
      return Left(ServerFailure());
    } on OfflineException {
      debugPrint('Home Repo :: searchForPlace :: OfflineException :: ');
      return Left(OfflineFailure());
    } catch (e) {
      debugPrint('Home Repo :: searchForPlace Exception :: $e');
      return Left(ServerFailure());
    }
  }

  Future<Either<Failure, DirectionModel>> getDirections(
      LatLng latLngOrigin, LatLng latLngDestination, bool isEnglish) async {
    try {
      final result = await homeRemoteData.getDirections(
          latLngOrigin, latLngDestination, isEnglish);
      return Right(result);
    } on ServerException {
      debugPrint('Home Repo :: getDirections :: ServerException :: ');
      return Left(ServerFailure());
    } on OfflineException {
      debugPrint('Home Repo :: getDirections :: OfflineException :: ');
      return Left(OfflineFailure());
    } catch (e) {
      debugPrint('Home Repo :: getDirections Exception :: $e');
      return Left(ServerFailure());
    }
  }

  double getDistanceBetween(LatLng origin, LatLng destination) {
    return homeLocalData.getDistanceBetween(origin, destination);
  }
}
