import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:waslny_user/features/theme/domain/usecases/get_theme_use_case.dart';
import 'package:waslny_user/features/theme/domain/usecases/set_theme_use_case.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/theme_entity.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final GetThemeUseCase getThemeUseCase;
  final SetThemeUseCase setThemeUseCase;
  ThemeCubit({required this.getThemeUseCase, required this.setThemeUseCase})
      : super(ThemeInitial());

  late ThemeMode selectedThemeMode;

  getTheme() {
    Either<Failure, ThemeEntity> either = getThemeUseCase();
    either.fold(
        (failure) => null, (success) => selectedThemeMode = success.themeMode);
  }

  setTheme(ThemeMode themeMode) async {
    Either<Failure, Unit> either =
        await setThemeUseCase(ThemeEntity(themeMode: themeMode));
    either.fold(
      (failure) => null,
      (success) {
        selectedThemeMode = themeMode;
        emit(ThemeChangedState(themeMode));
      },
    );
  }
}
