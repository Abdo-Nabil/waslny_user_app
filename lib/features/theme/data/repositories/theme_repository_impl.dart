import 'package:dartz/dartz.dart';
import 'package:waslny_user/core/error/failures.dart';
import 'package:waslny_user/features/theme/domain/entities/theme_entity.dart';
import 'package:waslny_user/features/theme/domain/repositories/theme_repository.dart';

import '../datasources/theme_local_data_source.dart';
import '../models/theme_model.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource themeLocalDataSource;
  const ThemeRepositoryImpl({required this.themeLocalDataSource});

  @override
  Either<Failure, ThemeEntity> getTheme() {
    ThemeModel themeModel = themeLocalDataSource.getTheme();
    return Right(ThemeEntity(themeMode: themeModel.themeMode));
  }

  @override
  Future<Either<Failure, Unit>> setTheme(ThemeEntity themeEntity) async {
    final result = await themeLocalDataSource
        .setTheme(ThemeModel(themeMode: themeEntity.themeMode));
    return Right(result);
  }
}
