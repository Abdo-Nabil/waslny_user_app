import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:waslny_user/core/extensions/context_extension.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/features/general_cubit/general_cubit.dart';
import 'package:waslny_user/resources/app_margins_paddings.dart';

import '../../config/routes/app_routes.dart';
import '../../resources/app_strings.dart';
import '../authentication/presentation/login_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    PageDecoration pageDecoration = PageDecoration(
      imagePadding: EdgeInsets.only(
        top: context.height * 0.05,
        right: AppPadding.p8,
        left: AppPadding.p8,
      ),
    );
    //
    return Scaffold(
      body: IntroductionScreen(
        isBottomSafeArea: true,
        isTopSafeArea: true,
        showDoneButton: true,
        done: Text(
          AppStrings.done.tr(context),
        ),
        onDone: () {
          BlocProvider.of<GeneralCubit>(context)
              .setInitialScreen(Routes.onBoardingRoute);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) {
              return const LoginScreen();
            }),
          );
        },
        showSkipButton: true,
        skip: Text(
          AppStrings.skip.tr(context),
        ),
        showNextButton: true,
        next: const Icon(Icons.arrow_forward),
        dotsDecorator: DotsDecorator(
          activeColor: Theme.of(context).colorScheme.secondary,
        ),
        pages: List.generate(3, (index) {
          return PageViewModel(
            title: 'title${index + 1}'.tr(context),
            body: 'description${index + 1}'.tr(context),
            image: Image.asset(
              'assets/images/title${index + 1}.jpg',
              fit: BoxFit.contain,
              height: context.height * 0.8,
              width: context.width * 0.8,
            ),
            decoration: pageDecoration,
          );
        }),
      ),
    );
  }
}
