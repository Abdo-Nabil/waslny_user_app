part of 'home_screen_cubit.dart';

abstract class HomeScreenState extends Equatable {
  const HomeScreenState();
}

class HomeScreenInitial extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class DialogMessageState extends HomeScreenState {
  final String msg;
  const DialogMessageState(this.msg);
  @override
  List<Object> get props => [identityHashCode(this)];
}

class HomeLoadingState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class HomeSuccessWithPopState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class HomeSuccessWithoutPopState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class HomeFailureState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class HomeConnectionFailureState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class HomeLocPermissionDeniedState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class AState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class SelectLocationLoadingState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class SelectLocationDoneState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class SelectLocationFailureState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class SearchPlaceSuccessState extends HomeScreenState {
  final List places;
  const SearchPlaceSuccessState(this.places);
  @override
  List<Object> get props => [places];
}

class SearchPlaceFailureState extends HomeScreenState {
  @override
  List<Object> get props => [];
}

class OpenAppSettingState extends HomeScreenState {
  final String msg;
  const OpenAppSettingState(this.msg);
  @override
  List<Object> get props => [identityHashCode(this)];
}

class OpenLocationSettingState extends HomeScreenState {
  final String msg;
  const OpenLocationSettingState(this.msg);
  @override
  List<Object> get props => [identityHashCode(this)];
}

class HomeRefreshMarkerState extends HomeScreenState {
  final String latLng;
  const HomeRefreshMarkerState(this.latLng);
  @override
  List<Object> get props => [latLng];
}
