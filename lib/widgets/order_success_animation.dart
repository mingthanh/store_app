import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderSuccessAnimation extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry padding;

  const OrderSuccessAnimation({
    super.key,
    this.size = 180,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(
            'assets/animations/order_success.json',
            repeat: false,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
