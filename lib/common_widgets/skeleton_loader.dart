import 'package:flutter/material.dart';

class SkeletonLoader extends StatelessWidget {
  final Widget child;
  final Widget skeleton;
  final bool isLoading;
  final Duration fadeDuration;

  const SkeletonLoader({
    Key? key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
    this.fadeDuration = const Duration(milliseconds: 250),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: isLoading ? 1.0 : 0.0,
          duration: fadeDuration,
          child: skeleton,
        ),
        AnimatedOpacity(
          opacity: isLoading ? 0.0 : 1.0,
          duration: fadeDuration,
          child: child,
        ),
      ],
    );
  }
}
