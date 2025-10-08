import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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