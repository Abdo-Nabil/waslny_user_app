import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:waslny_user/core/extensions/context_extension.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/util/no_animation_page_route.dart';
import 'package:waslny_user/core/util/toast_helper.dart';
import 'package:waslny_user/core/widgets/add_vertical_space.dart';
import 'package:waslny_user/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/text_row.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/timer_widget.dart';
import 'package:waslny_user/resources/app_margins_paddings.dart';
import 'package:waslny_user/resources/image_assets.dart';

import '../../../core/util/dialog_helper.dart';
import '../../../resources/app_strings.dart';
import '../../home_screen/presentation/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({
    required this.phoneNumber,
    Key? key,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    AltSmsAutofill().unregisterListener();
    _otpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    ToastHelper.initializeToast(context);
    super.initState();
  }

  initTimer() async {}

  initSmsListner() async {
    try {
      _otpController.text = (await AltSmsAutofill().listenForSms)!;
      await AuthCubit.getIns(context).verifySmsCode("${_otpController.text}");

      // await Future.delayed(const Duration(seconds: 3));
      // _otpController.text = '2';
      debugPrint('code ${_otpController.text}');
    } on PlatformException {
      debugPrint('SMS Problem');
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is StartLoadingState) {
          DialogHelper.loadingDialog(context);
        } else if (state is EndLoadingStateAndNavigate) {
          Navigator.of(context).pop();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute<void>(
          //     builder: (BuildContext context) => const HomeScreen(),
          //   ),
          // );
          Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomeScreen(),
            ),
            (route) => false,
          );
        } else if (state is EndLoadingStateWithError) {
          Navigator.of(context).pop();
        } else if (state is ResendSmsState) {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            NoAnimationPageRoute(
              builder: (BuildContext context) => OtpScreen(
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        } else if (state is EndLoadingStateWithSmsError) {
          Navigator.of(context).pop();
          ToastHelper.showToast(
              context, AppStrings.invalidSMS.tr(context), ToastStates.error);
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p16),
              child: Column(
                children: [
                  AddVerticalSpace(context.height * 0.03),
                  Image.asset(ImageAssets.AuthOtpImgPath),
                  AddVerticalSpace(context.height * 0.03),
                  Text(
                    AppStrings.phoneNumberVerification.tr(context),
                    style: Theme.of(context).textTheme.headline5?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const AddVerticalSpace(AppPadding.p16),
                  Text.rich(
                    TextSpan(
                      text: AppStrings.enterTheCodeSent.tr(context),
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              ' ${AppStrings.stars}${widget.phoneNumber.substring(7)}',
                          style:
                              Theme.of(context).textTheme.subtitle1?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const AddVerticalSpace(AppPadding.p28),
                  PinCodeTextField(
                    autoDisposeControllers: false,
                    appContext: context,
                    controller: _otpController,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    animationDuration: const Duration(milliseconds: 300),
                    // enableActiveFill: true,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(AppPadding.p16),
                      fieldHeight: 50,
                      fieldWidth: 50,
                    ),
                    // errorAnimationController: errorController,
                    // controller: textEditingController,
                    onCompleted: (v) async {
                      // debugPrint("Completed");
                      // AuthCubit.getIns(context).verifySmsCode(v);
                    },
                    onChanged: (_) {
                      // debugPrint("onChanged!");
                    },
                    beforeTextPaste: (text) {
                      // print("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  ),
                  const AddVerticalSpace(AppPadding.p16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(context.width - 32, 50)),
                    onPressed: () async {
                      await AuthCubit.getIns(context)
                          .verifySmsCode(_otpController.text);
                    },
                    child: Text(
                      AppStrings.verify.tr(context),
                    ),
                  ),
                  const AddVerticalSpace(AppPadding.p32),
                  const TimerWidget(),
                  const AddVerticalSpace(AppPadding.p12),
                  TextRow(
                    isResendButton: true,
                    text: AppStrings.didntRecieveTheCode,
                    textButton: AppStrings.resend,
                    onTap: () async {
                      await AuthCubit.getIns(context)
                          .resendSms(widget.phoneNumber);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
