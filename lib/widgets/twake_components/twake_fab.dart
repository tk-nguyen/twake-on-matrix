import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TwakeFloatingActionButton extends StatelessWidget {
  final Function()? onTap;

  final IconData? icon;

  final String? imagePath;

  final double size;

  const TwakeFloatingActionButton({
    super.key,
    this.onTap,
    this.icon,
    this.imagePath,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: icon != null
              ? Icon(
                  icon,
                  size: size,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                )
              : imagePath != null
                  ? SvgPicture.asset(imagePath!, width: size, height: size)
                  : null,
          ),
        ),
      ),
    );
  }

}