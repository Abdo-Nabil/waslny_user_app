import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waslny_user/config/routes/app_routes.dart';
import 'package:waslny_user/features/on_boarding/on_boarding_screen.dart';

import '../../resources/app_strings.dart';

part 'general_state.dart';

class GeneralCubit extends Cubit<GeneralState> {
  final SharedPreferences sharedPreferences;
  GeneralCubit({required this.sharedPreferences}) : super(GeneralInitial());

  late Widget selectedScreen;

  getInitialScreen() {
    final String? result = sharedPreferences.getString(AppStrings.storedRoute);
    if (result == null) {
      selectedScreen = const OnBoardingScreen();
    }
    //
    else {
      selectedScreen = Scaffold(
        backgroundColor: Colors.green,
      );
      //check if token found to navigate to login or home
    }
  }

  Future setInitialScreen(String routeName) async {
    await sharedPreferences.setString(
      AppStrings.storedRoute,
      routeName,
    );
  }
}
