import 'package:waslny_user/features/authentication/data/models/trip_model.dart';
import 'package:waslny_user/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final List<TripModel>? tripsModel;
  const UserModel({
    required super.userId,
    required super.phoneNumber,
    super.name,
    super.tripsEntity,
    this.tripsModel,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        phoneNumber,
        tripsModel,
        tripsEntity,
      ];

  factory UserModel.fromJson(Map<String, dynamic> map) {
    //
    final List<TripModel> trips = [];
    if (map['trips'] != null) {
      map['trips'].forEach((element) {
        trips.add(TripModel.fromJson(element));
      });
    }
    return UserModel(
      userId: map['userId'],
      phoneNumber: map['phoneNumber'],
      name: map['name'],
      tripsModel: trips,
    );
  }
  //
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> listOfMaps = [];

    if (tripsModel != null) {
      for (TripModel element in tripsModel!) {
        listOfMaps.add(element.toJson());
      }
    }
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'name': name,
      'trips': listOfMaps,
    };
  }
}

// UserModel({
//   required String userId,
//   required String phoneNumber,
//   String? name,
//   this.tripsModel,
// }) : super(
//         userId: userId,
//         phoneNumber: phoneNumber,
//         name: name,
//         tripsEntity: tripsModel != null
//             ? List<TripEntity>.generate(
//                 tripsModel.length,
//                 (index) => TripEntity(
//                     tripId: tripsModel[index].tripId,
//                     userId: tripsModel[index].userId,
//                     driverId: tripsModel[index].driverId,
//                     source: tripsModel[index].source,
//                     destination: tripsModel[index].destination,
//                     cost: tripsModel[index].cost,
//                     date: tripsModel[index].date,
//                     time: tripsModel[index].time,
//                     estimatedTime: tripsModel[index].estimatedTime,
//                     pathArray: tripsModel[index].pathArray,
//                     rating: tripsModel[index].rating),
//               )
//             : null,
//       );
