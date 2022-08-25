import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

class OfflineFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class EmptyCacheFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class GetCacheFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class CacheSavingFailure extends Failure {
  @override
  List<Object?> get props => [];
}
