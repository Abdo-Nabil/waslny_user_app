import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/features/home_screen/services/direction_model.dart';
import 'package:waslny_user/features/home_screen/services/home_repo.dart';
import 'package:waslny_user/resources/constants_manager.dart';

import '../../../resources/app_strings.dart';
import '../services/home_local_data.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  final HomeRepo homeRepo;
  HomeScreenCubit(this.homeRepo) : super(HomeScreenInitial());

  LatLng? myInitialLatLng;
  late Stream<LatLng> latLngStream;
  late bool _isOrigin;
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  List<LatLng> polyLinePointsList = [];
  late LatLng origin;
  late LatLng destination;
  DirectionModel? directionModel;

  getIsOrigin() {
    return _isOrigin;
  }

  setOrigin() {
    _isOrigin = true;
  }

  clearOrigin() {
    _isOrigin = false;
  }

  cleanMarkers() {
    markers = {};
  }

  emitInitialState() {
    emit(HomeScreenInitial());
  }

  static HomeScreenCubit getIns(BuildContext context) {
    return BlocProvider.of<HomeScreenCubit>(context);
  }

  String? validateField(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emptyValue.tr(context);
    } else {
      return null;
    }
  }

  Future<void> onMapCreatedCallback(GoogleMapController controller) async {
    mapController = controller;
    Stream<LatLng>? stream = await getMyLocationStream();
    myInitialLatLng = await stream?.first;
    animateCameraWithUserZoomLevel(myInitialLatLng);
    stream?.listen(
      (latLng) async {
        animateCameraWithUserZoomLevel(latLng);
      },
    );
  }

  animateCameraWithUserZoomLevel(LatLng? latLng) async {
    final userZoomLevel = await mapController.getZoomLevel();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng ?? cairoLatLng, zoom: userZoomLevel),
      ),
    );
  }

  void goToHome() {
    //
    if (myInitialLatLng != null) {
      animateCameraWithUserZoomLevel(myInitialLatLng);
    } else {
      animateCameraWithUserZoomLevel(cairoLatLng);
    }
  }

  void addMarker(BuildContext context) {
    //TODO: need more
    late LatLng point;
    if (_isOrigin) {
      point = origin;
    } else {
      point = destination;
    }
    markers.add(
      Marker(
        markerId: MarkerId('${point.latitude + point.longitude}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _isOrigin ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: _isOrigin
              ? AppStrings.startPosition.tr(context)
              : AppStrings.endPosition.tr(context),
        ),
        position: point,
      ),
    );
    if (_isOrigin) {
      animateCameraWithUserZoomLevel(origin);
    }

    emit(HomeSuccessWithoutPopState());
  }

  Future searchForPlace(
      GlobalKey<FormState> formKey, String value, bool isEnglish) async {
    if (formKey.currentState!.validate()) {
      emit(SelectLocationLoadingState());
      //
      await Future.delayed(const Duration(seconds: 3));

      final either = await homeRepo.searchForPlace(value, isEnglish);
      either.fold((failure) {
        emit(SearchPlaceFailureState());
      }, (success) {
        emit(SearchPlaceSuccessState(success));
      });
    }
  }

  Future getDirections(BuildContext context, bool isEnglish) async {
    addMarker(context);
    //
    emit(HomeLoadingState());
    await Future.delayed(const Duration(seconds: 3));

    final either = await homeRepo.getDirections(origin, destination, isEnglish);
    either.fold(
      (failure) {
        emit(HomeFailureState());
      },
      (success) {
        directionModel = success;
        polyLinePointsList = success.polyLinePoints;
        mapController.animateCamera(CameraUpdate.newLatLngBounds(
            success.bounds, ConstantsManager.mapPadding));
        emit(HomeSuccessWithPopState());
      },
    );
  }

  Future<Stream<LatLng>?> getMyLocationStream() async {
    //
    final either = await homeRepo.checkLocationPermissions();
    bool isOk = false;
    either.fold(
      (failure) {
        emit(HomeFailureState());
      },
      (success) {
        switch (success) {
          case LocPermission.disabled:
            emit(OpenLocationSettingState(AppStrings.locationServicesDisabled));
            break;

          case LocPermission.denied:
            emit(OpenAppSettingState(AppStrings.locationPermissionsDenied));
            break;

          case LocPermission.deniedForever:
            emit(OpenAppSettingState(
                AppStrings.locationPermissionsDeniedForEver));
            break;
          case LocPermission.done:
            isOk = true;
            break;
        }
      },
    );

    //
    if (isOk) {
      emit(HomeLoadingState());
      await Future.delayed(Duration(seconds: 3));
      final isConnected = await homeRepo.isConnected();
      if (isConnected) {
        final either = homeRepo.getMyLocationStream();

        return either.fold(
          (failure) {
            emit(HomeFailureState());
            return null;
          },
          (success) async {
            latLngStream = success;
            emit(HomeSuccessWithPopState());
            debugPrint('My Location $success');
            return success;
          },
        );
      }
      //
      else {
        emit(HomeConnectionFailureState());
        return null;
      }
    } else {
      emit(HomeLocPermissionDeniedState());
      return null;
    }
  }
  //

  void requestCar(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      //
      //request  car
    }
  }

  static const LatLng cairoLatLng = LatLng(
    31.2357116,
    30.0444196,
  );
  static const CameraPosition cairoCameraPosition = CameraPosition(
    target: LatLng(
      31.2357116,
      30.0444196,
    ),
    zoom: ConstantsManager.mapZoomLevel,
  );
  //

//
  /* Future getMyLocation() async {
    //
    final either = await homeRepo.checkLocationPermissions();
    bool isOk = false;
    either.fold(
      (failure) {
        emit(HomeFailureState());
      },
      (success) {
        switch (success) {
          case LocPermission.disabled:
            emit(OpenLocationSettingState(AppStrings.locationServicesDisabled));
            break;

          case LocPermission.denied:
            emit(OpenAppSettingState(AppStrings.locationPermissionsDenied));
            break;

          case LocPermission.deniedForever:
            emit(OpenAppSettingState(
                AppStrings.locationPermissionsDeniedForEver));
            break;
          case LocPermission.done:
            isOk = true;
            break;
        }
      },
    );

    //
    if (isOk) {
      emit(HomeLoadingState());
      final isConnected = await homeRepo.isConnected();
      if (isConnected) {
        final either = await homeRepo.getMyLocation();

        either.fold(
          (failure) {
            emit(HomeFailureState());
          },
          (success) async {
            myInitialLatLng = LatLng(
              success.latitude,
              success.longitude,
            );
            emit(HomeSuccessWithPopState());
            debugPrint('My Location $success');
          },
        );
      }
      //
      else {
        emit(HomeConnectionFailureState());
      }
    } else {
      emit(HomeLocPermissionDeniedState());
    }
  }*/
}
