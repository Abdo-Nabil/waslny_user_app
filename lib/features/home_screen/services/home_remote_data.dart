import 'dart:convert';
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

  Future<List<PlaceModel>> searchForPlace(String value, bool isEnglish) async {
    final String language = isEnglish ? 'en' : 'ar';
    String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$value&language=$language&key=$mapsApiKey';
    //
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      //
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        List<PlaceModel> placesList = [];
        for (var place in results) {
          placesList.add(PlaceModel.fromJson(place));
        }
        return placesList;
      } else {
        throw ServerException();
      }
    } else {
      throw OfflineException();
    }
  }

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
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'].isEmpty || data['routes'][0]['legs'].isEmpty) {
          throw ServerException();
        }
        return DirectionModel.fromJson(data);
      } else {
        throw ServerException();
      }
    } else {
      throw OfflineException();
    }
  }
}

/*DirectionsStatus

The status field within the Directions response object contains the status of the request, and may contain debugging information to help you track down why the Directions service failed. The status field may contain the following values:

OK indicates the response contains a valid result.
NOT_FOUND indicates at least one of the locations specified in the request's origin, destination, or waypoints could not be geocoded.
ZERO_RESULTS indicates no route could be found between the origin and destination.
MAX_WAYPOINTS_EXCEEDED indicates that too many waypoints were provided in the request. For applications using the Directions API as a web service, or the directions service in the Maps JavaScript API, the maximum allowed number of waypoints is 25, plus the origin and destination.
MAX_ROUTE_LENGTH_EXCEEDED indicates the requested route is too long and cannot be processed. This error occurs when more complex directions are returned. Try reducing the number of waypoints, turns, or instructions.
INVALID_REQUEST indicates that the provided request was invalid. Common causes of this status include an invalid parameter or parameter value.
OVER_DAILY_LIMIT indicates any of the following:
The API key is missing or invalid.
Billing has not been enabled on your account.
A self-imposed usage cap has been exceeded.
The provided method of payment is no longer valid (for example, a credit card has expired).
See the Maps FAQ to learn how to fix this.
OVER_QUERY_LIMIT indicates the service has received too many requests from your application within the allowed time period.
REQUEST_DENIED indicates that the service denied use of the directions service by your application.
UNKNOWN_ERROR indicates a directions request could not be processed due to a server error. The request may succeed if you try again. */

/*
PlacesSearchStatus

Status codes returned by service.

OK indicating the API request was successful.
ZERO_RESULTS indicating that the search was successful but returned no results. This may occur if the search was passed a latlng in a remote location.
INVALID_REQUEST indicating the API request was malformed, generally due to missing required query parameter (location or radius).
OVER_QUERY_LIMIT indicating any of the following:
You have exceeded the QPS limits.
Billing has not been enabled on your account.
The monthly $200 credit, or a self-imposed usage cap, has been exceeded.
The provided method of payment is no longer valid (for example, a credit card has expired).
See the Maps FAQ for more information about how to resolve this error.
REQUEST_DENIED indicating that your request was denied, generally because:
The request is missing an API key.
The key parameter is invalid.
UNKNOWN_ERROR indicating an unknown error.*/
