import 'package:flutter/material.dart';

class NoAnimationPageRoute extends MaterialPageRoute {
  NoAnimationPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(seconds: 0);
}
