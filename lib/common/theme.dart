import 'package:flutter/material.dart';

/// Full opacity gradient
const LinearGradient appLinearGradient = LinearGradient(
  colors: [
    Color.fromRGBO(255, 79, 64, 1), // #FF4F40
    Color.fromRGBO(255, 68, 221, 1), // #FF44DD
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final Shader loginLinearGradient = const LinearGradient(colors: <Color>[
  Color.fromRGBO(255, 79, 64, 100),
  Color.fromRGBO(255, 68, 221, 100)
], begin: Alignment.topLeft, end: Alignment.bottomRight)
    .createShader(const Rect.fromLTWH(0.0, 0.0, 500.0, 70.0));
