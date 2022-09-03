import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repo.dart';

class CreateUserUseCase extends UseCase<dynamic, String> {
  final AuthRepo authRepo;
  CreateUserUseCase({required this.authRepo});

  @override
  Future<Either<Failure, dynamic>> call(String params) async {
    return await authRepo.createUser(params);
  }
}
