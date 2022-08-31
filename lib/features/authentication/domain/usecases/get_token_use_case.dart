import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repo.dart';

class GetTokenUseCase {
  final AuthRepo authRepo;
  GetTokenUseCase({required this.authRepo});

  Either<Failure, String?> call() {
    return authRepo.getToken();
  }
}
