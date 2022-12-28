import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waslny_user/core/error/exceptions.dart';
import 'package:waslny_user/core/error/failures.dart';
import 'package:waslny_user/features/authentication/services/models/user_model.dart';
import 'package:waslny_user/features/home_screen/services/models/direction_model.dart';
import 'package:waslny_user/features/home_screen/services/models/place_model.dart';
import 'package:waslny_user/features/home_screen/services/home_remote_data.dart';

import '../../../core/network/network_info.dart';
import 'home_local_data.dart';
import 'models/active_captain_model.dart';
import 'models/active_user_model.dart';

class HomeRepo {
  final HomeRemoteData homeRemoteData;
  final HomeLocalData homeLocalData;
  final NetworkInfo networkInfo;
  HomeRepo(this.homeRemoteData, this.homeLocalData, this.networkInfo);

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
    return await networkInfo.isConnected;
  }

  Future<Either<Failure, List<PlaceModel>>> searchForPlace(
      String value, bool isEnglish) async {
    if (await networkInfo.isConnected) {
      //
      try {
        final result = await homeRemoteData.searchForPlace(value, isEnglish);
        return Right(result);
      } on ServerException {
        debugPrint('Home Repo :: searchForPlace :: ServerException :: ');
        return Left(ServerFailure());
      } catch (e) {
        debugPrint('Home Repo :: searchForPlace Exception :: $e');
        return Left(ServerFailure());
      }
      //
    } else {
      return Left(OfflineFailure());
    }
  }

  Future<Either<Failure, DirectionModel>> getDirections(
      LatLng latLngOrigin, LatLng latLngDestination, bool isEnglish) async {
    if (await networkInfo.isConnected) {
      //
      try {
        final result = await homeRemoteData.getDirections(
            latLngOrigin, latLngDestination, isEnglish);
        return Right(result);
      } on ServerException {
        debugPrint('Home Repo :: getDirections :: ServerException :: ');
        return Left(ServerFailure());
      } catch (e) {
        debugPrint('Home Repo :: getDirections Exception :: $e');
        return Left(ServerFailure());
      }
      //
    } else {
      return Left(OfflineFailure());
    }
  }

  Future<Either<Failure, List<ActiveCaptainModel>>> getActiveCaptains() async {
    if (await networkInfo.isConnected) {
      //
      try {
        final listOfCaptains = await homeRemoteData.getActiveCaptains();
        return Right(listOfCaptains);
      } catch (e) {
        debugPrint('HomeRepo :: getActiveCaptains :: $e');
        return Left(ServerFailure());
      }
      //
    } else {
      return Left(OfflineFailure());
    }
  }

  Future<Either<Failure, String>> convertLatLngToAddress(
      double lat, double lng) async {
    if (await networkInfo.isConnected) {
      //
      try {
        final result = await homeRemoteData.convertLatLngToAddress(lat, lng);
        return Right(result);
      } on ServerException {
        debugPrint(
            'Home Repo :: convertLatLngToAddress :: ServerException :: ');
        return Left(ServerFailure());
      } catch (e) {
        debugPrint('Home Repo :: convertLatLngToAddress Exception :: $e');
        return Left(ServerFailure());
      }
      //
    } else {
      return Left(OfflineFailure());
    }
  }

  Future<Either<Failure, Unit>> selectCaptain(
      ActiveCaptainModel captain, ActiveUserModel activeUserModel) async {
    if (await networkInfo.isConnected) {
      //
      try {
        await homeRemoteData.selectCaptain(captain, activeUserModel);
        return Future.value(const Right(unit));
      } catch (e) {
        debugPrint('HomeRepo :: selectCaptain :: $e');
        return Left(ServerFailure());
      }
      //
    } else {
      return Left(OfflineFailure());
    }
  }

  double getDistanceBetween(LatLng origin, LatLng destination) {
    return homeLocalData.getDistanceBetween(origin, destination);
  }
}
