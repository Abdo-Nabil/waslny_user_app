import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waslny_user/core/error/failures.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/util/dialog_helper.dart';
import 'package:waslny_user/features/authentication/cubits/auth_cubit.dart';
import 'package:waslny_user/features/authentication/services/models/user_model.dart';
import 'package:waslny_user/features/home_screen/services/home_repo.dart';
import 'package:waslny_user/features/home_screen/services/models/active_captain_model.dart';
import 'package:waslny_user/features/home_screen/services/models/active_user_model.dart';
import 'package:waslny_user/features/home_screen/services/models/message_type.dart';
import 'package:waslny_user/features/localization/presentation/cubits/localization_cubit.dart';
import 'package:waslny_user/resources/constants_manager.dart';
import 'package:waslny_user/resources/image_assets.dart';

import '../../../resources/app_strings.dart';
import '../../general/services/general_repo.dart';
import '../services/home_local_data.dart';
import '../services/models/direction_model.dart';

part 'home_screen_state.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  final HomeRepo homeRepo;
  final GeneralRepo generalRepo;
  HomeScreenCubit(this.homeRepo, this.generalRepo) : super(HomeScreenInitial());

  LatLng? myInitialLatLng;
  late LatLng myCurrentLatLng;
  late Stream<LatLng> latLngStream;
  late bool _isOrigin;
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  List<LatLng> polyLinePointsList1 = [];
  List<LatLng> polyLinePointsList2 = [];
  late LatLng origin;
  late LatLng destination;
  Marker? originMarker;
  Marker? destinationMarker;
  DirectionModel? directionModel1;
  DirectionModel? directionModel2;
  late BitmapDescriptor markerCustomIcon;
  TextEditingController? toController;
  TextEditingController? fromController;
  List<ActiveCaptainModel> readyCaptains = [];
  late RemoteMessage message1;
  late RemoteMessage message2;
  late LatLng captainCurrentLatLng;
  bool waitingForCaptainResponseFlag = true;

  //
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

  Marker _getCurrentLocationMarker(LatLng latLng) {
    return Marker(
      markerId: const MarkerId('current location marker'),
      position: latLng,
      icon: markerCustomIcon,
    );
  }

  Future<void> onMapCreatedCallback(GoogleMapController controller) async {
    mapController = controller;
    markerCustomIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, ImageAssets.markerImgPath);
    //
    Stream<LatLng>? stream = await getMyLocationStream();
    if (stream != null) {
      //
      myInitialLatLng = await stream.first;
      myCurrentLatLng = myInitialLatLng!;
      //TODO: hint null value above
      markers.add(_getCurrentLocationMarker(myCurrentLatLng));
      emit(HomeRefreshMarkerState('$myCurrentLatLng'));
      animateCameraWithUserZoomLevel(myInitialLatLng!);
      stream.listen(
        (latLng) async {
          markers.remove(_getCurrentLocationMarker(myCurrentLatLng));
          myCurrentLatLng = latLng;
          markers.add(_getCurrentLocationMarker(myCurrentLatLng));
          animateCameraWithUserZoomLevel(latLng);

          emit(HomeRefreshMarkerState('$latLng'));
        },
      );
      //
    } else {
      animateCameraWithUserZoomLevel(cairoLatLng);
    }
  }

  getDistanceBetween(LatLng origin, LatLng destination) {
    final distanceInMetres = homeRepo.getDistanceBetween(origin, destination);
  }

  animateCameraWithUserZoomLevel(LatLng latLng) async {
    final userZoomLevel = await mapController.getZoomLevel();
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: userZoomLevel),
      ),
    );
  }

  void goToHome() {
    //
    if (myInitialLatLng != null) {
      animateCameraWithUserZoomLevel(myInitialLatLng!);
    } else {
      animateCameraWithUserZoomLevel(cairoLatLng);
    }
  }

  void addOrgOrDesMarker(BuildContext context) {
    if (_isOrigin) {
      //
      originMarker != null ? markers.remove(originMarker) : () {};
      destinationMarker != null ? markers.remove(destinationMarker) : () {};
      polyLinePointsList2.clear();
      //
      originMarker = Marker(
        markerId: const MarkerId('origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(title: AppStrings.startPosition.tr(context)),
        position: origin,
      );
      markers.add(
        originMarker!,
      );
      animateCameraWithUserZoomLevel(origin);
      emit(HomeSuccessWithoutPopState());
    } else {
      destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: AppStrings.endPosition.tr(context),
        ),
        position: destination,
      );
      markers.add(
        destinationMarker!,
      );
      emit(HomeSuccessWithoutPopState());
    }
  }

  Future searchForPlace(
      GlobalKey<FormState> formKey, String value, bool isEnglish) async {
    if (formKey.currentState!.validate()) {
      emit(SelectLocationLoadingState());
      //
      await Future.delayed(const Duration(seconds: 3));

      final either = await homeRepo.searchForPlace(value, isEnglish);
      either.fold((failure) {
        if (failure.runtimeType == ServerFailure) {
          emit(SearchPlaceServerFailureState());
        } else if (failure.runtimeType == OfflineFailure) {
          emit(SearchPlaceConnectionFailureState());
        }
      }, (success) {
        emit(SearchPlaceSuccessState(success));
      });
    }
  }

  Future getDestinationDirections(BuildContext context, bool isEnglish) async {
    //
    emit(HomeLoadingState());
    await Future.delayed(const Duration(seconds: 3));

    final either = await homeRepo.getDirections(origin, destination, isEnglish);
    either.fold(
      (failure) {
        if (failure.runtimeType == ServerFailure) {
          emit(HomeServerFailureWithPopState());
        } else if (failure.runtimeType == OfflineFailure) {
          emit(HomeConnectionFailureWithPopState());
        }
      },
      (success) {
        directionModel2 = success;
        polyLinePointsList2 = success.polyLinePoints;
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
        emit(HomeFailureWithoutPopState());
      },
      (success) {
        switch (success) {
          case LocPermission.disabled:
            // ignore: prefer_const_constructors
            emit(OpenLocationSettingState(AppStrings.locationServicesDisabled));
            break;

          case LocPermission.denied:
            // ignore: prefer_const_constructors
            emit(OpenAppSettingState(AppStrings.locationPermissionsDenied));
            break;

          case LocPermission.deniedForever:
            // ignore: prefer_const_constructors
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
      await Future.delayed(const Duration(seconds: 3));
      final isConnected = await homeRepo.isConnected();
      if (isConnected) {
        final either = homeRepo.getMyLocationStream();

        return either.fold(
          (failure) {
            emit(HomeServerFailureWithPopState());
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

  Future<String?> _convertLatLngToAddress(double lat, double lng) async {
    final either = await homeRepo.convertLatLngToAddress(lat, lng);
    return either.fold(
      (l) {
        debugPrint('Error while converting from LatLng to address');
        return null;
      },
      (r) {
        return r;
      },
    );
  }

  void requestCar(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      emit(HomeLoadingState());
      final either = await homeRepo.getActiveCaptains();
      either.fold(
        (failure) {
          emit(HomeServerFailureWithPopState());
        },
        (success) async {
          await Future.delayed(const Duration(seconds: 3));
          final filteredCaptains = filterCaptains(success);
          if (filteredCaptains.length == 0) {
            emit(NoCaptainsAvailable());
          } else {
            readyCaptains = filteredCaptains;
            emit(EndLoadingToCaptainsScreen());
          }
        },
      );
    }
  }

  selectCaptain(
    BuildContext context,
    ActiveCaptainModel captain,
  ) async {
    emit(HomeLoadingWithTimerState());
    waitingForCaptainResponseFlag = true;
    //
    String? originString = fromController?.text;
    if (fromController?.text == AppStrings.myCurrentLocation.tr(context)) {
      originString =
          await _convertLatLngToAddress(origin.latitude, origin.longitude);
      if (originString == null) {
        emit(HomeServerFailureWithPopState());
        return;
      }
    }
    //
    final activeUserModel = ActiveUserModel(
      userModel: AuthCubit.getIns(context).userData,
      userDeviceToken: generalRepo.getString(AppStrings.fcmToken)!,
      origin: originString!,
      destination: toController!.text,
      latLngOrigin: origin,
      latLngDestination: destination,
    );
    //
    final either = await homeRepo.selectCaptain(captain, activeUserModel);
    either.fold(
      (failure) {
        emit(HomeServerFailureWithPopState());
      },
      (success) {
        emit(HomeScreenInitial());
        manageTheTimer(context);
      },
    );
  }

  manageTheTimer(BuildContext context) {
    Timer(
        const Duration(
            seconds: ConstantsManager.userAndCaptainRequestTimeDuration + 5),
        () {
      if (waitingForCaptainResponseFlag) {
        Navigator.pop(context);
        DialogHelper.messageDialog(
            context, AppStrings.captainNotResponding.tr(context));
      }
    });
  }

  filterCaptains(List<ActiveCaptainModel> list) {
    return list;
  }

  Future _getCaptainPath(BuildContext context, bool isEnglish) async {
    //
    emit(HomeLoadingState());
    await Future.delayed(const Duration(seconds: 3));

    final either =
        await homeRepo.getDirections(captainCurrentLatLng, origin, isEnglish);
    either.fold(
      (failure) {
        if (failure.runtimeType == ServerFailure) {
          emit(HomeServerFailureWithPopState());
        } else if (failure.runtimeType == OfflineFailure) {
          emit(HomeConnectionFailureWithPopState());
        }
      },
      (success) {
        directionModel1 = success;
        polyLinePointsList1 = success.polyLinePoints;
        mapController.animateCamera(CameraUpdate.newLatLngBounds(
            success.bounds, ConstantsManager.mapPadding));
        emit(HomeSuccessWithPopState());
        Navigator.of(context).pop();
      },
    );
  }

  handleMessage(RemoteMessage message, BuildContext context) async {
    if (waitingForCaptainResponseFlag) {
      waitingForCaptainResponseFlag = false;
      Navigator.pop(context);
    }
    //
    if (message.data['messageType'] == MessageType.confirm.name) {
      final temp1 = jsonDecode(message.data['captainCurrentLocation']);
      captainCurrentLatLng = LatLng(temp1['lat'], temp1['lng']);
      _getCaptainPath(
          context, LocalizationCubit.getIns(context).isEnglishLocale());
    } else if (message.data['messageType'] == MessageType.reject.name) {
      DialogHelper.messageDialogWithDoublePop(
          context, AppStrings.captainRejectTrip.tr(context));
    }
  }

  static const LatLng cairoLatLng = LatLng(
    31.2357116,
    30.0444196,
  );
  static const CameraPosition cairoCameraPosition = CameraPosition(
    target: cairoLatLng,
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
        emit(HomeFailureWithoutPopState());
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
            emit(HomeFailureWithPopState());
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
