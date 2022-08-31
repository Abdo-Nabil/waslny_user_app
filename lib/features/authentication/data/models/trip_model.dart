import 'package:waslny_user/features/authentication/domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  TripModel({
    required super.tripId,
    required super.userId,
    required super.driverId,
    required super.source,
    required super.destination,
    required super.cost,
    required super.date,
    required super.time,
    required super.estimatedTime,
    required super.pathArray,
    required super.rating,
  });

  factory TripModel.fromJson(Map<String, dynamic> map) {
    return TripModel(
      tripId: map['tripId'],
      userId: map['userId'],
      driverId: map['driverId'],
      source: map['source'],
      destination: map['destination'],
      cost: map['cost'],
      date: map['date'],
      time: map['time'],
      estimatedTime: map['estimatedTime'],
      pathArray: map['pathArray'],
      rating: map['rating'],
    );
  }
  //
  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'userId': userId,
      'driverId': driverId,
      'source': source,
      'destination': destination,
      'cost': cost,
      'date': date,
      'time': time,
      'estimatedTime': estimatedTime,
      'pathArray': pathArray,
      'rating': rating,
    };
  }
}

// TripModel({
//   required String tripId,
//   required String userId,
//   required String driverId,
//   required String source,
//   required String destination,
//   required double cost,
//   required String date,
//   required String time,
//   required String estimatedTime,
//   required List pathArray,
//   required double rating,
// }) : super(
//         tripId: tripId,
//         userId: userId,
//         driverId: driverId,
//         source: source,
//         destination: destination,
//         cost: cost,
//         date: date,
//         time: time,
//         estimatedTime: estimatedTime,
//         pathArray: pathArray,
//         rating: rating,
//       );
