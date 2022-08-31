import 'package:equatable/equatable.dart';
import 'package:waslny_user/features/authentication/domain/entities/trip_entity.dart';

class UserEntity extends Equatable {
  final String userId;
  final String phoneNumber;
  final String? name;
  final List<TripEntity>? tripsEntity;

  const UserEntity({
    required this.userId,
    required this.phoneNumber,
    this.name,
    this.tripsEntity,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        phoneNumber,
        tripsEntity,
      ];
}
