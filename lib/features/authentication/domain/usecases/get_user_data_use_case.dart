import 'package:dartz/dartz.dart';
import 'package:waslny_user/features/authentication/domain/entities/user_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repo.dart';

class GetUserDataUseCase extends UseCase<UserEntity, String> {
  final AuthRepo authRepo;
  GetUserDataUseCase({required this.authRepo});

  @override
  Future<Either<Failure, UserEntity>> call(String params) async {
    return await authRepo.getUserData(params);
  }
}
