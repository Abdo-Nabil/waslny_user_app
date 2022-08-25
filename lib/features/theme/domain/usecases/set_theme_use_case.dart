import 'package:dartz/dartz.dart';
import 'package:waslny_user/core/error/failures.dart';
import 'package:waslny_user/core/usecases/usecase.dart';

import '../entities/theme_entity.dart';
import '../repositories/theme_repository.dart';

class SetThemeUseCase implements UseCase<Unit, ThemeEntity> {
  final ThemeRepository themeRepository;
  const SetThemeUseCase({required this.themeRepository});

  @override
  Future<Either<Failure, Unit>> call(ThemeEntity themeEntity) async {
    return await themeRepository.setTheme(themeEntity);
  }
}
