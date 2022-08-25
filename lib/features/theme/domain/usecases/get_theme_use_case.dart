import 'package:dartz/dartz.dart';
import 'package:waslny_user/features/theme/domain/repositories/theme_repository.dart';

import '../../../../core/error/failures.dart';
import '../entities/theme_entity.dart';

class GetThemeUseCase {
  final ThemeRepository themeRepository;
  const GetThemeUseCase({required this.themeRepository});

  Either<Failure, ThemeEntity> call() {
    return themeRepository.getTheme();
  }
}
