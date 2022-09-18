import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waslny_user/core/extensions/context_extension.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/widgets/custom_form_field.dart';
import 'package:waslny_user/core/widgets/no_x_widget.dart';
import 'package:waslny_user/features/home_screen/cubits/home_screen_cubit.dart';
import 'package:waslny_user/features/home_screen/presentation/widgets/location_item.dart';
import 'package:waslny_user/features/home_screen/services/place_model.dart';
import 'package:waslny_user/resources/app_margins_paddings.dart';
import 'package:waslny_user/resources/colors_manager.dart';
import 'package:waslny_user/resources/image_assets.dart';

import '../../../resources/app_strings.dart';
import '../../localization/presentation/cubits/localization_cubit.dart';

class SelectLocationScreen extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const SelectLocationScreen({
    required this.label,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  Timer? _timer;
  bool isCurrentlySearching = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    final PlaceItem? myCurrentLocationPlaceItem =
        HomeScreenCubit.getIns(context).getIsOrigin()
            ? PlaceItem(
                controller: widget.controller,
                isGreenColor: true,
                placeModel: PlaceModel(
                  name: AppStrings.myCurrentLocation.tr(context),
                  placeId: 'MyCurrentLocation',
                  location: HomeScreenCubit.getIns(context).myInitialLatLng ??
                      HomeScreenCubit.cairoLatLng,
                ),
              )
            : null;
    //
    final bool isEnglishLocale =
        LocalizationCubit.getIns(context).isEnglishLocale();
    //
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: BlocBuilder<HomeScreenCubit, HomeScreenState>(
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppPadding.p20),
                      bottomRight: Radius.circular(AppPadding.p20),
                    ),
                    color: ColorsManager.greyBlack,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      AppPadding.p40,
                      0,
                      AppPadding.p16,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppPadding.p16),
                              child: CustomFormFiled(
                                context: context,
                                autoFocus: true,
                                controller: widget.controller,
                                label: widget.label,
                                iconWidget: const Icon(Icons.search),
                                onFieldSubmitted: (value) async {
                                  await _onSearch(value, isEnglishLocale);
                                },
                                validate: (value) {
                                  return HomeScreenCubit.getIns(context)
                                      .validateField(context, value);
                                },
                                onChange: (String value) async {
                                  _onChange(value, isEnglishLocale);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<HomeScreenCubit, HomeScreenState>(
                  builder: (context, state) {
                    if (state is SearchPlaceSuccessState) {
                      if (state.places.isEmpty) {
                        return _myLocationAndWidget(
                          context,
                          myCurrentLocationPlaceItem,
                          Expanded(
                            child: NoXWidget(
                              msg: AppStrings.notFoundLocation.tr(context),
                              imagePath: ImageAssets.notFoundImgPath,
                            ),
                          ),
                        );
                      }
                      //
                      else {
                        return Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            itemCount: state.places.length,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    myCurrentLocationPlaceItem ?? Container(),
                                    PlaceItem(
                                      placeModel: state.places[index],
                                      controller: widget.controller,
                                    ),
                                  ],
                                );
                              }
                              return PlaceItem(
                                placeModel: state.places[index],
                                controller: widget.controller,
                              );
                            },
                          ),
                        );
                      }
                    }

                    //
                    else if (state is SearchPlaceFailureState) {
                    }
                    //
                    else if (state is SelectLocationLoadingState) {
                      return _myLocationAndWidget(
                        context,
                        myCurrentLocationPlaceItem,
                        SizedBox(
                          height: context.height * 0.60,
                          width: double.infinity,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    //
                    return _myLocationAndWidget(
                      context,
                      myCurrentLocationPlaceItem,
                      Expanded(
                        child: NoXWidget(
                          msg: AppStrings.searchForLocation.tr(context),
                          imagePath: ImageAssets.searchImgPath,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future _onSearch(String value, bool isEnglishLocale) async {
    if (!isCurrentlySearching) {
      isCurrentlySearching = true;
      await HomeScreenCubit.getIns(context).searchForPlace(
        _formKey,
        value,
        isEnglishLocale,
      );
      isCurrentlySearching = false;
    }
  }

  _onChange(String value, bool isEnglishLocale) async {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(
      Duration(milliseconds: value.isEmpty ? 0 : 2000),
      () async {
        if (value.length > 1) {
          await _onSearch(value, isEnglishLocale);
        } else if (value.isEmpty) {
          HomeScreenCubit.getIns(context).emitInitialState();
        }
      },
    );
  }
}

_myLocationAndWidget(
    BuildContext context, Widget? nullWidget, Widget mainWidget) {
  return SizedBox(
    height: context.height * 0.70,
    child: Column(
      children: [
        nullWidget ?? Container(),
        mainWidget,
      ],
    ),
  );
}
