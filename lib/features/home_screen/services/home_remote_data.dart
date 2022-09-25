import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waslny_user/core/error/exceptions.dart';
import 'package:waslny_user/core/network/network_info.dart';
import 'package:waslny_user/features/home_screen/services/place_model.dart';

import '../../../sensitive/constants.dart';
import 'package:http/http.dart' as http;

import 'direction_model.dart';

class HomeRemoteData {
  final NetworkInfo networkInfo;
  final http.Client client;
  HomeRemoteData({
    required this.networkInfo,
    required this.client,
  });

  Future<bool> isConnected() async {
    return await networkInfo.isConnected;
  }

  //
  //https://developers.google.com/maps/documentation/places/web-service/search-text#PlacesSearchStatus
  //
  Future<List<PlaceModel>> searchForPlace(String value, bool isEnglish) async {
    final String language = isEnglish ? 'en' : 'ar';
    String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$value&language=$language&key=$mapsApiKey';
    //
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      //
      final response = await client.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
        final List results = data['results'];
        List<PlaceModel> placesList = [];
        for (var place in results) {
          placesList.add(PlaceModel.fromJson(place));
        }
        return placesList;
      } else {
        debugPrint(
            "Home remote data searchForPlace Exception :: ${data['status']}");
        throw ServerException();
      }
    } else {
      throw OfflineException();
    }
  }

  //
  //https://developers.google.com/maps/documentation/directions/get-directions#DirectionsStatus
  //
  Future<DirectionModel> getDirections(
      LatLng latLngOrigin, LatLng latLngDestination, bool isEnglish) async {
    final String language = isEnglish ? 'en' : 'ar';
    final origin = '${latLngOrigin.latitude},${latLngOrigin.longitude}';
    final destination =
        '${latLngDestination.latitude},${latLngDestination.longitude}';
    //
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&language=$language&key=$mapsApiKey';
    final isConnected = await networkInfo.isConnected;
    //
    if (isConnected) {
      //
      final response = await client.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        if (data['routes'].isEmpty || data['routes'][0]['legs'].isEmpty) {
          throw ServerException();
        }
        return DirectionModel.fromJson(data);
      } else {
        debugPrint(
            "Home remote data getDirections Exception :: ${data['status']}");
        throw ServerException();
      }
    } else {
      throw OfflineException();
    }
  }
}
