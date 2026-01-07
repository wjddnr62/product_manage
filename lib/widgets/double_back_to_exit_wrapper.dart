import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleBackToExitWrapper extends StatefulWidget {
  const DoubleBackToExitWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<DoubleBackToExitWrapper> createState() => _DoubleBackToExitWrapperState();
}

class _DoubleBackToExitWrapperState extends State<DoubleBackToExitWrapper> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        final now = DateTime.now();
        final wasBackPressedRecently = _lastBackPressed != null &&
            now.difference(_lastBackPressed!) < const Duration(seconds: 2);

        if (wasBackPressedRecently) {
          SystemNavigator.pop(); // 앱 종료
        } else {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('앱을 종료하시겠습니까?'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: widget.child,
    );
  }
}
