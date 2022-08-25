part of 'auth_cubit.dart';

@immutable
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class ButtonStateEnabled extends AuthState {
  @override
  List<Object?> get props => [];
}

class ButtonStateDisabled extends AuthState {
  @override
  List<Object?> get props => [];
}
