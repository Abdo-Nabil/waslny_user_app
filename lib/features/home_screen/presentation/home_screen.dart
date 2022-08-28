import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wa'),
      ),
      body: Center(
        child: Text(
          'home screen',
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
    );
  }
}
