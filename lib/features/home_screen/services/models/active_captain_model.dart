import 'package:equatable/equatable.dart';

class ActiveCaptainModel extends Equatable {
  final String captainId;
  final String email;
  final String name;
  final String phone;
  final String age;
  final String gender;
  final String carModel;
  final String plateNumber;
  final String carColor;
  final String productionDate;
  final String numOfPassengers;
  final String? ratting;
  final double lat;
  final double lng;
  const ActiveCaptainModel({
    required this.captainId,
    required this.email,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    required this.carModel,
    required this.plateNumber,
    required this.carColor,
    required this.productionDate,
    required this.numOfPassengers,
    this.ratting,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [
        captainId,
        email,
        name,
        phone,
        age,
        gender,
        carModel,
        plateNumber,
        carColor,
        productionDate,
        numOfPassengers,
        ratting,
        lat,
        lng,
      ];

  factory ActiveCaptainModel.fromJson(Map<String, dynamic> map) {
    //['captainModel']
    return ActiveCaptainModel(
      captainId: map['captainModel']['captainId'],
      email: map['captainModel']['email'],
      name: map['captainModel']['name'],
      phone: map['captainModel']['phone'],
      age: map['captainModel']['age'],
      gender: map['captainModel']['gender'],
      carModel: map['captainModel']['carModel'],
      plateNumber: map['captainModel']['plateNumber'],
      carColor: map['captainModel']['carColor'],
      productionDate: map['captainModel']['productionDate'],
      numOfPassengers: map['captainModel']['numOfPassengers'],
      ratting: map['captainModel']['ratting'],
      lat: map['latLng']['lat'],
      lng: map['latLng']['lng'],
    );
  }
  //not used ... modify them if you want to use them!
  /*Map<String, dynamic> toJson() {
    return {
      'captainId': captainId,
      'email': email,
      'name': name,
      'phone': phone,
      'age': age,
      'gender': gender,
      'carModel': carModel,
      'plateNumber': plateNumber,
      'carColor': carColor,
      'productionDate': productionDate,
      'numOfPassengers': numOfPassengers,
      'ratting': ratting,
      'lat': lat,
      'lng': lng,
    };
  }*/
}
