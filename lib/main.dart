import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc_observer.dart';
import 'injection_container.dart' as di;
import 'my_app.dart';

Future<void> main() async {
  //Avoid printing in Release Mode if you use debugPrint
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  //
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}
