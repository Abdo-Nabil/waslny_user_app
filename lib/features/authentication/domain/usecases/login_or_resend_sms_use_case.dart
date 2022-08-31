import 'package:dartz/dartz.dart';
import 'package:waslny_user/core/error/failures.dart';
import 'package:waslny_user/core/usecases/usecase.dart';
import 'package:waslny_user/features/authentication/domain/repositories/auth_repo.dart';

class LoginOrResendSmsUseCase extends UseCase<dynamic, String> {
  final AuthRepo authRepo;
  LoginOrResendSmsUseCase({required this.authRepo});

  @override
  Future<Either<Failure, dynamic>> call(String params) async {
    return await authRepo.loginOrResendSms(params);
  }
}
