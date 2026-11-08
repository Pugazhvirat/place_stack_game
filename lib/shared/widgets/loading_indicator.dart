import 'package:flutter/material.dart';
import 'package:place_stack/app/theme/colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 3, color: AppColors.neonBlue),
      ),
    );
  }
}
