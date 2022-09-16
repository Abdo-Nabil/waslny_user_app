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

  CameraPosition? homeCameraPosition;
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
    await getMyLocation();
    //
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(homeCameraPosition ?? cairoPosition),
    );
  }

  void goToHome() {
    final cameraPosition = homeCameraPosition ?? cairoPosition;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
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

  Future getMyLocation() async {
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
          (success) {
            homeCameraPosition = CameraPosition(
              target: LatLng(
                success.latitude,
                success.longitude,
              ),
              zoom: ConstantsManager.mapZoomLevel,
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
  }

  void requestCar(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      //
      //request  car
    }
  }

  static const CameraPosition cairoPosition = CameraPosition(
    target: LatLng(
      31.2357116,
      30.0444196,
    ),
    zoom: ConstantsManager.mapZoomLevel,
  );
  //

}

final map = {
  "geocoded_waypoints": [
    {
      "geocoder_status": "OK",
      "place_id": "ChIJ4bzQkc3O9xQRHDoItU4KZTM",
      "types": ["premise"]
    },
    {
      "geocoder_status": "OK",
      "place_id": "ChIJl9lcZFLJ9xQR9NeDOutX1aA",
      "types": ["premise"]
    }
  ],
  "routes": [
    {
      "bounds": {
        "northeast": {"lat": 30.76239959999999, "lng": 31.0213693},
        "southwest": {"lat": 30.7468027, "lng": 30.9985918}
      },
      "copyrights": "Map data ©2022",
      "legs": [
        {
          "distance": {"text": "3.5 km", "value": 3538},
          "duration": {"text": "10 mins", "value": 618},
          "end_address":
              "QX7X+97M, Nafya, Tanta, Gharbia Governorate 6621101, Egypt",
          "end_location": {"lat": 30.76239959999999, "lng": 30.9985918},
          "start_address":
              "Q22C+8GC, Nafya, Tanta, Gharbia Governorate 6642252, Egypt",
          "start_location": {"lat": 30.7508909, "lng": 31.021194},
          "steps": [
            {
              "distance": {"text": "23 m", "value": 23},
              "duration": {"text": "1 min", "value": 4},
              "end_location": {"lat": 30.7507701, "lng": 31.0209951},
              "html_instructions": "Head <b>south-west</b>",
              "polyline": {"points": "a`uzDmyi|DFJNX"},
              "start_location": {"lat": 30.7508909, "lng": 31.021194},
              "travel_mode": "DRIVING"
            },
            {
              "distance": {"text": "0.2 km", "value": 223},
              "duration": {"text": "2 mins", "value": 93},
              "end_location": {"lat": 30.7488381, "lng": 31.0213693},
              "html_instructions": "Turn <b>left</b>",
              "maneuver": "turn-left",
              "polyline": {
                "points":
                    "i_uzDgxi|DNGLGTKBCBAFCp@KFARAH@J@JBj@BNBH?F?B@FAB?DAFAJADAFAB?@A`AW"
              },
              "start_location": {"lat": 30.7507701, "lng": 31.0209951},
              "travel_mode": "DRIVING"
            },
            {
              "distance": {"text": "85 m", "value": 85},
              "duration": {"text": "1 min", "value": 33},
              "end_location": {"lat": 30.7486365, "lng": 31.0205177},
              "html_instructions": "Turn <b>right</b>",
              "maneuver": "turn-right",
              "polyline": {"points": "gstzDqzi|DJZBLJb@Hh@@L@PAN?@"},
              "start_location": {"lat": 30.7488381, "lng": 31.0213693},
              "travel_mode": "DRIVING"
            },
            {
              "distance": {"text": "0.3 km", "value": 307},
              "duration": {"text": "2 mins", "value": 107},
              "end_location": {"lat": 30.7468027, "lng": 31.0182228},
              "html_instructions": "Slight <b>left</b>",
              "maneuver": "turn-slight-left",
              "polyline": {
                "points":
                    "_rtzDgui|DTj@N\\LZPNDD@BNNLLHHXVTTDBPLRP@Bf@`@^\\NL\\^HJDFHP@DBJBT@P"
              },
              "start_location": {"lat": 30.7486365, "lng": 31.0205177},
              "travel_mode": "DRIVING"
            },
            {
              "distance": {"text": "2.9 km", "value": 2900},
              "duration": {"text": "6 mins", "value": 381},
              "end_location": {"lat": 30.76239959999999, "lng": 30.9985918},
              "html_instructions": "Turn <b>right</b>",
              "maneuver": "turn-right",
              "polyline": {
                "points":
                    "oftzD{fi|Du@ZUJiCpAk@XsAp@cAh@cDbBeEvBeCpAkB`AgEvBkB`AcCnAqBbASJwDhBiD|A_CbAuClAQHqAh@sB|@qBz@wAn@u@^eAh@]Ro@^o@`@]VKLMPEFQZA@a@z@Qb@Oh@G`@?@CZCb@Ab@?PAzBCpB?d@AjACfD?jCEtCKzJAbCCzCAlB?|@?n@Cl@?DEd@Gd@G^"
              },
              "start_location": {"lat": 30.7468027, "lng": 31.0182228},
              "travel_mode": "DRIVING"
            }
          ],
          "traffic_speed_entry": [],
          "via_waypoint": []
        }
      ],
      "overview_polyline": {
        "points":
            "a`uzDmyi|DVd@\\Od@Ux@M\\?rAL\\?PC\\EbAYNh@TlAB^APd@hALZPNFH`A~@jC|B|@`AJVF`@@Pu@Z_D|AgJxE_SbKuJ`FaJfEuGpCiIlDmCnAcB|@_B`Ai@d@g@v@s@~AWjAIdBEdHErFE`HShWC`DUjB"
      },
      "summary": "",
      "warnings": [],
      "waypoint_order": []
    }
  ],
  "status": "OK"
};
