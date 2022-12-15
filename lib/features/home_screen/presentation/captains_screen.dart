import 'package:flutter/material.dart';
import 'package:waslny_user/core/extensions/string_extension.dart';
import 'package:waslny_user/core/widgets/add_vertical_space.dart';
import 'package:waslny_user/features/home_screen/services/models/active_captain_model.dart';
import 'package:waslny_user/features/localization/presentation/cubits/localization_cubit.dart';

import '../../../resources/app_margins_paddings.dart';
import '../../../resources/app_strings.dart';
import '../cubits/home_screen_cubit.dart';

class CaptainsScreen extends StatelessWidget {
  const CaptainsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ActiveCaptainModel> readyCaptains =
        HomeScreenCubit.getIns(context).readyCaptains;
    // final List<ActiveCaptainModel> readyCaptains = [
    //   ActiveCaptainModel(
    //       captainId: 'dsadas',
    //       email: 'asdadas',
    //       name: 'name',
    //       phone: 'phone',
    //       age: '55',
    //       gender: 'gender',
    //       carModel: 'carModel',
    //       plateNumber: 'plateNumber',
    //       carColor: 'carColor',
    //       productionDate: 'productionDate',
    //       numOfPassengers: 'numOfPassengers',
    //       lat: 55.0,
    //       lng: 24.0),
    //   ActiveCaptainModel(
    //       captainId: 'dsadas',
    //       email: 'asdadas',
    //       name: 'name',
    //       phone: 'phone',
    //       age: '55',
    //       gender: 'gender',
    //       carModel: 'carModel',
    //       plateNumber: 'plateNumber',
    //       carColor: 'carColor',
    //       productionDate: 'productionDate',
    //       numOfPassengers: 'numOfPassengers',
    //       lat: 55.0,
    //       lng: 24.0),
    //   ActiveCaptainModel(
    //       captainId: 'dsadas',
    //       email: 'asdadas',
    //       name: 'name',
    //       phone: 'phone',
    //       age: '55',
    //       gender: 'gender',
    //       carModel: 'carModel',
    //       plateNumber: 'plateNumber',
    //       carColor: 'carColor',
    //       productionDate: 'productionDate',
    //       numOfPassengers: 'numOfPassengers',
    //       lat: 55.0,
    //       lng: 24.0),
    //   ActiveCaptainModel(
    //       name: 'name',
    //       email: 'asdadas',
    //       gender: 'gender',
    //       carModel: 'carModel',
    //       plateNumber: 'plateNumber',
    //       carColor: 'carColor',
    //       productionDate: 'productionDate',
    //       numOfPassengers: 'numOfPassengers',
    //       age: '55',
    //       phone: 'phone',
    //       captainId: 'dsadas',
    //       lat: 55.0,
    //       lng: 24.0),
    // ];
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.readyCaptains.tr(context))),
      body: ListView.builder(
          itemCount: readyCaptains.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                //show are you sure dialog
                //send a notification to the captain
                //if the captain refuse ==> pop to the home page
                //if the captain accept calculate the distance between them and show the route in red line
                //continue the process ....
              },
              child: Column(
                children: [
                  const AddVerticalSpace(AppPadding.p8),
                  Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.symmetric(horizontal: AppPadding.p8),
                    padding: const EdgeInsets.all(AppPadding.p16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppPadding.p20),
                      color: Colors.black.withOpacity(0.650),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${AppStrings.name.tr(context)}: ${readyCaptains[index].name}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${AppStrings.age.tr(context)}: ${readyCaptains[index].age}'),
                            Text(
                                '${AppStrings.gender.tr(context)}: ${readyCaptains[index].gender.tr(context)}'),
                          ],
                        ),
                        LocalizationCubit.getIns(context).isEnglishLocale()
                            ? Text(
                                '${AppStrings.car.tr(context)}: ${readyCaptains[index].carColor}  ${readyCaptains[index].carModel}  ${readyCaptains[index].productionDate}')
                            : Text(
                                '${AppStrings.car.tr(context)}: ${readyCaptains[index].carModel}  ${readyCaptains[index].carColor}  ${readyCaptains[index].productionDate}'),
                        Text(
                            '${AppStrings.plateNumber.tr(context)}: ${readyCaptains[index].plateNumber}'),
                        Text(
                            '${AppStrings.numOfPassengers.tr(context)}: ${readyCaptains[index].numOfPassengers}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
