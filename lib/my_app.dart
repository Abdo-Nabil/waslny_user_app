import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waslny_user/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:waslny_user/features/authentication/presentation/login_screen.dart';
import 'package:waslny_user/features/authentication/presentation/otp_screen.dart';
import 'package:waslny_user/features/general_cubit/general_cubit.dart';
import 'package:waslny_user/features/localization/presentation/cubits/localization_cubit.dart';
import 'package:waslny_user/features/theme/presentation/cubits/theme_cubit.dart';
import 'package:waslny_user/resources/app_strings.dart';

import 'config/routes/app_routes.dart';
import 'core/util/toast_helper.dart';
import 'features/localization/locale/app_localizations_setup.dart';
import 'features/theme/app_theme.dart';
import 'injection_container.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    // debugInvertOversizedImages = true;
    //
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<LocalizationCubit>()..getLocale()),
        BlocProvider(create: (context) => sl<ThemeCubit>()..getTheme()),
        BlocProvider(
            create: (context) => sl<GeneralCubit>()..getInitialScreen()),
        BlocProvider(create: (context) => sl<AuthCubit>()),
      ],
      child: BlocBuilder<LocalizationCubit, LocalizationState>(
        builder: (context, state) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              //
              final Locale selectedLocale =
                  BlocProvider.of<LocalizationCubit>(context).selectedLocale;
              final ThemeMode selectedThemeMode =
                  BlocProvider.of<ThemeCubit>(context).selectedThemeMode;
              final Widget initialScreen =
                  BlocProvider.of<GeneralCubit>(context).selectedScreen;
              //
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: AppStrings.appName_for_recent_app,
                theme: AppTheme.lightTheme(selectedLocale, context),
                darkTheme: AppTheme.darkTheme(selectedLocale, context),
                themeMode: ThemeMode.dark,
                onGenerateRoute: AppRoutes.onGenerateRoute,
                supportedLocales: AppLocalizationsSetup.supportedLocales,
                locale: selectedLocale,
                // // localeResolutionCallback:
                //     AppLocalizationsSetup.localeResolutionCallback,
                localizationsDelegates:
                    AppLocalizationsSetup.localizationsDelegates,
                // home: const OtpScreen(phoneNumber: '1111522423'),
                home: const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
