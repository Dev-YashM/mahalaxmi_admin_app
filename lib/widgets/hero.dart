import 'package:flutter/material.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'heroWidget',
      child: Image.asset('assets/images/lightLogo.png'),
    );
  }
}
