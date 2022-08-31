import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repo.dart';

class VerifySmsCodeUseCase {
  final AuthRepo authRepo;
  VerifySmsCodeUseCase({required this.authRepo});

  Future<Either<Failure, dynamic>> call(String smsCode) async {
    return await authRepo.verifySmsCode(smsCode);
  }
}
