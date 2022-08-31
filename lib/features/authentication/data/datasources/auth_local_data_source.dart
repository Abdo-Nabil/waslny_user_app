import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../resources/app_strings.dart';

abstract class AuthLocalDataSource {
  String? getToken();
  Future setToken(String token);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  String? getToken() {
    final String? result = sharedPreferences.getString(AppStrings.storedToken);
    return result;
  }

  @override
  Future setToken(String token) async {
    final bool result =
        await sharedPreferences.setString(AppStrings.storedToken, token);
    if (!result) {
      throw CacheSavingException();
    }
  }
}
