import 'dart:ui';

import 'package:flutter/widgets.dart';

class BlurOverlayRoute<T> extends PageRoute<T> {
  BlurOverlayRoute({
    required this.builder,
    this.barrierLabel,
    this.backgroundColor = const Color(0xFF000000),
    this.backgroundOpacity = 0.25,
    this.blur = 4.5,
    RouteSettings? settings,
  }) : super(
          settings: settings,
        );

  @override
  Color get barrierColor => const Color(0x00000001);

  @override
  bool get barrierDismissible => true;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  final String? barrierLabel;

  final WidgetBuilder builder;

  final Color backgroundColor;

  final double backgroundOpacity;

  final double blur;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: builder(context),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return BlurTransition(
      blurAnimation: Tween<double>(
        begin: 0,
        end: blur,
      ).animate(animation),
      backgroundColorAnimation: Tween<double>(
        begin: 0,
        end: backgroundOpacity,
      ).animate(animation),
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 355);
}

class BlurTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> blurAnimation;
  final Animation<double>? backgroundColorAnimation;
  final Color? backgroundColor;

  const BlurTransition({
    Key? key,
    required this.blurAnimation,
    required this.child,
    this.backgroundColorAnimation,
    this.backgroundColor,
  }) : super(key: key, listenable: blurAnimation);

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (backgroundColorAnimation != null && backgroundColor != null) {
      color = backgroundColor!.withOpacity(backgroundColorAnimation!.value);
    }

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: blurAnimation.value,
        sigmaY: blurAnimation.value,
      ),
      child: Container(
        color: color,
        child: child,
      ),
    );
  }
}
