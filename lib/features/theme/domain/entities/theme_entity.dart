import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeEntity extends Equatable {
  final ThemeMode themeMode;
  const ThemeEntity({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}
