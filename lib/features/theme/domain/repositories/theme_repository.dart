import 'package:dartz/dartz.dart';
import 'package:waslny_user/features/theme/domain/entities/theme_entity.dart';

import '../../../../core/error/failures.dart';

abstract class ThemeRepository {
  Either<Failure, ThemeEntity> getTheme();
  Future<Either<Failure, Unit>> setTheme(ThemeEntity themeEntity);
}
