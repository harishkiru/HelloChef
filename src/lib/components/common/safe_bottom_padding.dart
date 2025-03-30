import 'package:flutter/material.dart';

class SafeBottomPadding extends StatelessWidget {
  final Widget child;
  final double extraPadding;

  const SafeBottomPadding({
    super.key,
    required this.child,
    this.extraPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom + extraPadding;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: child,
    );
  }
}
