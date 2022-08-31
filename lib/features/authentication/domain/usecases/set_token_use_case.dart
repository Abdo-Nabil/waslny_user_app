import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repo.dart';

class SetTokenUseCase {
  final AuthRepo authRepo;
  SetTokenUseCase({required this.authRepo});

  Future<Either<Failure, Unit>> call(String token) async {
    return await authRepo.setToken(token);
  }
}
