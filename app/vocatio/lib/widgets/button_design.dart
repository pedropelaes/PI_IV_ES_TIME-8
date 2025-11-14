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

Widget cancelButtonDesign({
  required BuildContext context,
  required String label,
  required VoidCallback onTap,
  required double width,
  required double height,
}){
  final ThemeData theme = Theme.of(context);
  return InkWell(
    onTap: onTap,
    child: redTransparentContainer(
      theme: theme, 
      width: width,
      height: height,
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error
          ),
        ),
      )
    ),
  );
}

Widget primaryButtonDesign({
  required BuildContext context,
  required String label,
  required VoidCallback onTap,
  required double width,
  required double height,
  bool? enabled
}){
  final ThemeData theme = Theme.of(context);
  final bool isEnabled = enabled ?? true;
  return InkWell(
    splashColor: theme.colorScheme.inversePrimary,
    onTap: isEnabled ? onTap : null,
    child: Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
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
    ),
  );
}

Widget onPrimaryStyleButtonDesign({
  required BuildContext context,
  required Widget label,
  required VoidCallback onTap,
  required IconData icon,
  required double width,
  required double height,
}){
  final ThemeData theme = Theme.of(context);
  return InkWell(
    splashColor: theme.colorScheme.onPrimaryFixed,
    onTap: onTap,
    child: onPrimaryStyleContainer(
      theme: theme, 
      width: width,
      height: height,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 24,
                color: theme.colorScheme.primaryFixedDim,
              ),
              SizedBox(width: 12,),
              label
            ],
          ),
        ),
      )
    ),
  );
}