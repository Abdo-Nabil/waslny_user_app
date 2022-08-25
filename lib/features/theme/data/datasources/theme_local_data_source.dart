import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waslny_user/features/theme/data/models/theme_model.dart';

import '../../../../resources/app_strings.dart';

abstract class ThemeLocalDataSource {
  ThemeModel getTheme();
  Future<Unit> setTheme(ThemeModel themeModel);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final SharedPreferences sharedPreferences;
  const ThemeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  ThemeModel getTheme() {
    final bool? isLightTheme =
        sharedPreferences.getBool(AppStrings.isLightTheme);
    if (isLightTheme != null) {
      if (isLightTheme) {
        return const ThemeModel(themeMode: ThemeMode.light);
      } else {
        return const ThemeModel(themeMode: ThemeMode.dark);
      }
    }
    //
    else {
      return const ThemeModel(themeMode: ThemeMode.system);
    }
  }

  @override
  Future<Unit> setTheme(ThemeModel themeModel) async {
    switch (themeModel.themeMode) {
      //
      case ThemeMode.system:
        {
          await sharedPreferences.remove(AppStrings.isLightTheme);
        }
        break;
      //
      case ThemeMode.light:
        {
          await sharedPreferences.setBool(AppStrings.isLightTheme, true);
        }
        break;
      //
      case ThemeMode.dark:
        {
          await sharedPreferences.setBool(AppStrings.isLightTheme, false);
        }
        break;
      //
    }
    return Future.value(unit);
  }
}
