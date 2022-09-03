import 'package:flutter/material.dart';
import 'package:waslny_user/features/authentication/presentation/cubits/auth_cubit.dart';
import 'package:waslny_user/features/authentication/presentation/widgets/button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wa'),
      ),
      body: Column(
        children: [
          Text(
            'home screen',
            style: Theme.of(context).textTheme.headline3,
          ),
          Button(
            text: 'clicl Me',
            onTap: () async {
              await AuthCubit.getIns(context)
                  .getUserDataUseCase
                  .call('tbtUztHA2aPCmsNE1qZH9aEwmgy1');
            },
          ),
        ],
      ),
    );
  }
}
