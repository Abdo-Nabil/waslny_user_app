import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/util/dialog_helper.dart';
import 'package:waslny_user/core/util/navigator_helper.dart';
import 'package:waslny_user/features/authentication/cubits/auth_cubit.dart';
import 'package:waslny_user/features/home_screen/presentation/captains_screen.dart';
import 'package:waslny_user/features/home_screen/presentation/widgets/positioned_form_container.dart';
import 'package:waslny_user/features/home_screen/presentation/widgets/map_container.dart';
import 'package:waslny_user/features/home_screen/presentation/widgets/positioned_hamb_icon.dart';
import 'package:waslny_user/features/home_screen/presentation/widgets/positioned_loc_icon.dart';
import 'package:waslny_user/features/home_screen/presentation/widgets/positioned_yellow_chip.dart';

import '../../../resources/app_strings.dart';
import '../cubits/home_screen_cubit.dart';
import '../services/models/direction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //
  @override
  void initState() {
    HomeScreenCubit.getIns(context).getMyLocationStream();
    AuthCubit.getIns(context).getUserData();
    initFirebaseMessaging();
    super.initState();
  }

  //
  @override
  Widget build(BuildContext context) {
    //
    //make listen:false if you want to remove the yellow container
    final DirectionModel? directionModel =
        BlocProvider.of<HomeScreenCubit>(context, listen: true).directionModel;
    //
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: BlocListener<HomeScreenCubit, HomeScreenState>(
        listener: (context, state) {
          //
          if (state is HomeLoadingState) {
            DialogHelper.loadingDialog(context);
          }
          //
          else if (state is HomeConnectionFailureState) {
            Navigator.pop(context);
            DialogHelper.messageDialog(
                context, AppStrings.internetConnectionError.tr(context));
          }
          //
          else if (state is HomeLocPermissionDeniedState) {
            DialogHelper.messageDialog(
                context, AppStrings.givePermission.tr(context));
          }
          //
          else if (state is HomeServerFailureWithPopState) {
            Navigator.pop(context);
            DialogHelper.messageDialog(
                context, AppStrings.someThingWentWrong.tr(context));
          }
          //
          else if (state is HomeConnectionFailureWithPopState) {
            Navigator.pop(context);
            DialogHelper.messageDialog(
                context, AppStrings.internetConnectionError.tr(context));
          }
          //
          else if (state is HomeFailureWithoutPopState) {
            DialogHelper.messageDialog(
                context, AppStrings.someThingWentWrong.tr(context));
          }
          //
          else if (state is OpenAppSettingState) {
            DialogHelper.messageWithActionDialog(context, state.msg.tr(context),
                () async {
              await Geolocator.openAppSettings();
            });
          }
          //
          else if (state is OpenLocationSettingState) {
            DialogHelper.messageWithActionDialog(context, state.msg.tr(context),
                () async {
              await Geolocator.openLocationSettings();
            });
          }
          //
          else if (state is HomeSuccessWithPopState) {
            Navigator.pop(context);
          }
          //
          else if (state is NoCaptainsAvailable) {
            Navigator.pop(context);
            DialogHelper.messageDialog(
                context, AppStrings.noCaptainsAvailable.tr(context));
          }
          //
          else if (state is EndLoadingToCaptainsScreen) {
            Navigator.pop(context);
            NavigatorHelper.push(context, const CaptainsScreen());
          }
          //
        },
        child: Scaffold(
          //TODO: Note
          // resizeToAvoidBottomInset: false,
          body: Stack(
            alignment: Alignment.center,
            children: [
              const MapContainer(),
              directionModel != null
                  ? PositionedYellowChip(
                      text:
                          '${directionModel.distance}, ${directionModel.duration}',
                    )
                  : Container(),
              const PositionedLocIcon(),
              const PositionedHambIcon(),
              const PositionedFormContainer(),
            ],
          ),
        ),
      ),
    );
  }

  initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // request permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission:::::: ${settings.authorizationStatus}');
  }
}
