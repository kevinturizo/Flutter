import 'package:flutter/material.dart';

/// Logo de Taurus GYM — usa el asset PNG del logo corporativo.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 180});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/taurus_logo.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}

