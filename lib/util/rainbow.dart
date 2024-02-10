import 'package:flutter/material.dart';
import 'package:rainbow_color/rainbow_color.dart';

class RainbowAnimation {
  Animation<Color> animation;
  AnimationController controller;

  RainbowAnimation({
    required this.animation,
    required this.controller,
  });

  static init(TickerProvider widget, Function setState) {
    var controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: widget);

    var animation = RainbowColorTween([
      Colors.pink,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ]).animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Repeat
          controller.reset();
          controller.forward();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    controller.forward();

    return RainbowAnimation(animation: animation, controller: controller);
  }

  dispose() {
    controller.dispose();
  }
}
