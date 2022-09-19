import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:waslny_user/core/extensions/context_extension.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/util/dialog_helper.dart';
import 'package:waslny_user/core/util/navigator_helper.dart';
import 'package:waslny_user/core/widgets/add_vertical_space.dart';
import 'package:waslny_user/core/widgets/custom_form_field.dart';
import 'package:waslny_user/features/home_screen/presentation/select_location_screen.dart';
import 'package:waslny_user/features/home_screen/presentation/widgets/rounded_widget.dart';
import 'package:waslny_user/features/home_screen/services/direction_model.dart';
import 'package:waslny_user/resources/app_margins_paddings.dart';
import 'package:waslny_user/resources/colors_manager.dart';
import 'package:waslny_user/resources/constants_manager.dart';
import 'package:waslny_user/resources/font_manager.dart';

import '../../../resources/app_strings.dart';
import '../../localization/presentation/cubits/localization_cubit.dart';
import '../cubits/home_screen_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  late GoogleMapController _mapsController;
  // late Stream<LatLng> latLngStream;
  //
  @override
  void initState() {
    HomeScreenCubit.getIns(context).getMyLocationStream();
    super.initState();
  }

  //
  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _mapsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //

    final DirectionModel? directionModel =
        HomeScreenCubit.getIns(context).directionModel;
    //
    final bool isEnglishLocale =
        LocalizationCubit.getIns(context).isEnglishLocale();
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
          else if (state is HomeFailureState) {
            Navigator.pop(context);
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
        },
        child: Scaffold(
          //TODO: Note
          // resizeToAvoidBottomInset: false,
          body: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.blueGrey,
                child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: HomeScreenCubit.cairoCameraPosition,
                  onMapCreated: (GoogleMapController controller) async {
                    await HomeScreenCubit.getIns(context)
                        .onMapCreatedCallback(controller);
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('overView'),
                      color: ColorsManager.redColor,
                      width: ConstantsManager.polyLineWidth,
                      points: BlocProvider.of<HomeScreenCubit>(context,
                              listen: true)
                          .polyLinePointsList,
                    ),
                  },
                  markers:
                      BlocProvider.of<HomeScreenCubit>(context, listen: true)
                          .markers,
                ),
              ),
              directionModel != null
                  ? Positioned(
                      top: AppPadding.p40,
                      child: Container(
                        //Note The solver is BoxConstraints
                        constraints: BoxConstraints(
                          maxWidth: context.width * 0.60,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppPadding.p6,
                          horizontal: AppPadding.p12,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsManager.yellowAccent,
                          borderRadius: BorderRadius.circular(AppPadding.p20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2.0),
                              blurRadius: 6.0,
                            )
                          ],
                        ),
                        child: Text(
                          '${directionModel.distance}, ${directionModel.duration}',
                          style: TextStyle(
                            fontSize: FontSize.s20,
                            color: ColorsManager.greyBlack,
                            fontWeight: FontWeightManager.medium,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Positioned(
                left: isEnglishLocale ? AppPadding.p16 : null,
                right: isEnglishLocale ? null : AppPadding.p16,
                top: AppPadding.p38,
                child: RoundedWidget(
                  iconData: Icons.menu,
                  onTap: () {
                    //TODO :
                  },
                ),
              ),
              Positioned(
                left: isEnglishLocale ? null : AppPadding.p16,
                right: isEnglishLocale ? AppPadding.p16 : null,
                top: AppPadding.p38,
                child: RoundedWidget(
                  iconData: Icons.my_location,
                  onTap: () async {
                    HomeScreenCubit.getIns(context).goToHome();
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorsManager.greyBlack,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(AppPadding.p20),
                      topLeft: Radius.circular(AppPadding.p20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsManager.greyBlack,
                        offset: const Offset(0.0, 1.0), //(x,y)
                        blurRadius: AppPadding.p6,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.p8),
                    child: SizedBox(
                      height: context.height * 0.265,
                      width: context.width - AppPadding.p16,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const AddVerticalSpace(AppPadding.p8),
                              CustomFormFiled(
                                context: context,
                                label: AppStrings.from,
                                readOnly: true,
                                iconWidget:
                                    const Icon(Icons.add_location_alt_outlined),
                                controller: _fromController,
                                onTap: () {
                                  HomeScreenCubit.getIns(context).setOrigin();
                                  HomeScreenCubit.getIns(context)
                                      .emitInitialState();
                                  NavigatorHelper.push(
                                    context,
                                    SelectLocationScreen(
                                      label: AppStrings.pickUpLocation,
                                      controller: _fromController,
                                    ),
                                  );
                                },
                              ),
                              const AddVerticalSpace(AppPadding.p16),
                              CustomFormFiled(
                                context: context,
                                readOnly: true,
                                label: AppStrings.whereToGo,
                                iconWidget:
                                    const Icon(Icons.add_location_alt_outlined),
                                controller: _toController,
                                onTap: () {
                                  HomeScreenCubit.getIns(context).clearOrigin();
                                  HomeScreenCubit.getIns(context)
                                      .emitInitialState();
                                  NavigatorHelper.push(
                                    context,
                                    SelectLocationScreen(
                                      controller: _toController,
                                      label: AppStrings.to,
                                    ),
                                  );
                                },
                              ),
                              const AddVerticalSpace(AppPadding.p16),
                              ElevatedButton(
                                onPressed: () {
                                  HomeScreenCubit.getIns(context)
                                      .requestCar(_formKey);
                                },
                                child: Text(
                                  AppStrings.requestCar.tr(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
