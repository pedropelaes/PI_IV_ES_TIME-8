import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocattio/widgets/background_containers.dart';

Widget ButtonDesign({
  required BuildContext context,
  required String childText,
  required VoidCallback onPressed
}){
  final ThemeData theme = Theme.of(context);
  return PlatformElevatedButton(
    onPressed: onPressed,
    color: theme.colorScheme.primary,
    child: Text(
      childText,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onPrimary
      ),
    ),
  );
}

Widget bigTransparentButtonDesign({
  required BuildContext context,
  required String label,
  required VoidCallback onTap,
}){
  final ThemeData theme = Theme.of(context);
  return InkWell(
    onTap: onTap,
    child: transparentContainer(
      theme: theme, 
      width: 255.0, 
      height: 55.0,
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface
          ),
        ),
      ), 
    ),
  );
}

Widget primaryButtonDesign({
  required BuildContext context,
  required String label,
  required VoidCallback onTap,
  required double width,
  required double height,
}){
  final ThemeData theme = Theme.of(context);
  return InkWell(
    splashColor: theme.colorScheme.inversePrimary,
    onTap: onTap,
    child: primaryGradientContainer(
      theme: theme, 
      width: width,
      height: height,
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onPrimary
          ),
        ),
      )
    ),
  );
}