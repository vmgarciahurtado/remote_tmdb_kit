import 'package:flutter/material.dart';

class ContentShell extends StatelessWidget {
  const ContentShell({
    required this.child,
    required this.heightFactor,
    super.key,
  });

  final Widget child;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * heightFactor,
      child: child,
    );
  }
}
