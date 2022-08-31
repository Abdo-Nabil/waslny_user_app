import 'package:dartz/dartz.dart';
import 'package:waslny_user/features/authentication/domain/entities/user_entity.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repo.dart';

class CreateUserUseCase extends UseCase<dynamic, UserEntity> {
  final AuthRepo authRepo;
  CreateUserUseCase({required this.authRepo});

  @override
  Future<Either<Failure, dynamic>> call(UserEntity params) async {
    return await authRepo.createUser(params);
  }
}
