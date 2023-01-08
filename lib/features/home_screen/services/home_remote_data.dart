import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waslny_user/core/error/exceptions.dart';
import 'package:waslny_user/features/home_screen/services/models/active_captain_model.dart';
import 'package:waslny_user/features/home_screen/services/models/active_user_model.dart';
import 'package:waslny_user/features/home_screen/services/models/message_type.dart';
import 'package:waslny_user/features/home_screen/services/models/place_model.dart';

import '../../../sensitive/constants.dart';
import 'package:http/http.dart' as http;

import '../../authentication/services/models/user_model.dart';
import 'models/direction_model.dart';

class HomeRemoteData {
  final http.Client client;

  HomeRemoteData({
    required this.client,
  });

  //
  //https://developers.google.com/maps/documentation/places/web-service/search-text#PlacesSearchStatus
  //
  Future<List<PlaceModel>> searchForPlace(String value, bool isEnglish) async {
    final String language = isEnglish ? 'en' : 'ar';
    String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$value&language=$language&key=$mapsApiKey';
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
  }

  Future<List<ActiveCaptainModel>> getActiveCaptains() async {
    try {
      List<ActiveCaptainModel> listOfCaptains = [];
      final db = FirebaseFirestore.instance;
      final listOfMaps = await db.collection('activeCaptains').get();
      listOfMaps.docs.map((element) {
        listOfCaptains.add(ActiveCaptainModel.fromJson(element.data()));
      }).toList();
      return listOfCaptains;
    } catch (e) {
      debugPrint('HomeRemoteDate :: getActiveCaptains :: $e');
      throw ServerException();
    }
  }

  Future<String> convertLatLngToAddress(double lat, double lng) async {
    //
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapsApiKey';
    final response = await client.get(Uri.parse(url));
    final data = json.decode(response.body);
    if (data['status'] == 'OK') {
      if (data['results'].length == 0) {
        throw ServerException();
      }
      return data['results'][0]['formatted_address'];
    } else {
      debugPrint(
          "Home remote data convertLatLngToAddress Exception :: ${data['status']}");
      throw ServerException();
    }
  }

  Future selectCaptain(
      ActiveCaptainModel captain, ActiveUserModel activeUserModel) async {
    final response = await client.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'content-Type': 'application/json',
        'Authorization': 'key=$fcmServerKey',
      },
      body: jsonEncode(
        {
          'to': captain.deviceToken,
          'priority': 'high',
          'notification': {
            'title': 'Are you ready? ',
            'body': 'A new customer is waiting your response!',
          },
          'data': {
            'messageType': MessageType.captainToUserFirstRequest.name,
            'userId': activeUserModel.userModel.userId,
            'name': activeUserModel.userModel.name,
            'phoneNumber': activeUserModel.userModel.phoneNumber,
            'userDeviceToken': activeUserModel.userDeviceToken,
            'origin': activeUserModel.origin,
            'destination': activeUserModel.destination,
            'latLngOrigin': {
              'lat': activeUserModel.latLngOrigin.latitude,
              'lng': activeUserModel.latLngOrigin.longitude,
            },
            'latLngDestination': {
              'lat': activeUserModel.latLngDestination.latitude,
              'lng': activeUserModel.latLngDestination.longitude,
            }
          }
        },
      ),
    );

    if (response.statusCode != 200) {
      throw ServerException();
    }
  }
}
