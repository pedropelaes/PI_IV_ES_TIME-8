import 'package:flutter/material.dart';


Widget surfaceGradientContainer({
    required BuildContext context,
    required Widget child,
    bool horizontal = true
  })
  {
  final ThemeData theme = Theme.of(context);
  return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(
        colors: [theme.colorScheme.surface, theme.colorScheme.surfaceBright],
        stops: [0.34, 1.0],
        begin: horizontal ? Alignment.centerLeft : Alignment.topCenter,
        end: horizontal ? Alignment.centerRight : Alignment.bottomCenter
      )
    ),
    child: child,
  );
}


Widget primaryFormsContainer({
  required ThemeData theme,
  required Widget child,
}){
  final Brightness currentBrightness = theme.brightness;
  final bool isDarkMode = currentBrightness == Brightness.dark;
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
           isDarkMode ? theme.colorScheme.onPrimaryFixed : theme.colorScheme.primaryContainer, 
           isDarkMode ? theme.colorScheme.onPrimaryFixedVariant : theme.colorScheme.primaryContainer
          ]
        ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40)
      )
    ),
    padding: EdgeInsets.all(24.0),
    child: child
  );
}

Widget transparentContainer({
  required ThemeData theme,
  required Widget child,
  required double width,
  required double height,
}){
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      border: Border.all(
        width: 2.0,
        color: theme.colorScheme.onSurface
      )
    ),
    child: child,
  );
}

Widget redTransparentContainer({
  required ThemeData theme,
  required Widget child,
  required double width,
  required double height,
}){
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      border: Border.all(
        width: 2.0,
        color: theme.colorScheme.error
      )
    ),
    child: child,
  );
}

Widget primaryGradientContainer({
  required ThemeData theme,
  required Widget child,
  required double width,
  required double height,
}){
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      gradient: LinearGradient(
        colors: [theme.colorScheme.primary, theme.colorScheme.onPrimaryContainer],
        stops: [0.42, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: child,
  );
}

Container onPrimaryStyleContainer({
    required ThemeData theme,
    required Widget child,
    required double width,
    double? height,
}){
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      gradient: LinearGradient(
        colors: [theme.colorScheme.onPrimaryFixed, Color(0xFF9B71D9)],
        stops: [0, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: child,
  );
}

Container primaryFixedGradientContainer({
    required ThemeData theme,
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? padding
}){
  return Container(
    width: width,
    height: height,
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      gradient: LinearGradient(
        colors: [theme.colorScheme.onPrimaryFixed, theme.colorScheme.onPrimaryFixedVariant],
        stops: [0, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: child,
  );
}

Container tertiaryContainer({
  required ThemeData theme,
  required Widget child,
  double? width,
  double? height,
  EdgeInsets? padding
}){
return Container(
    width: width,
    height: height,
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: theme.colorScheme.tertiaryContainer
    ),
    child: child,
  );
}

Container tertiaryGradientContainer({
  required ThemeData theme,
  required Widget child,
  double? width,
  double? height,
  EdgeInsets? padding,
  bool right = false,
}){
  final bool isDark = theme.brightness == Brightness.dark;
return Container(
    width: width,
    height: height,
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      gradient: LinearGradient(
        colors: isDark ? [theme.colorScheme.tertiaryContainer, theme.colorScheme.onTertiary] : [theme.colorScheme.onTertiaryFixed, theme.colorScheme.onTertiaryFixedVariant],
        stops: [0, 1.0],
        begin: right ? Alignment.centerLeft : Alignment.centerRight,
        end: right ? Alignment.centerRight : Alignment.centerLeft,
      ),
    ),
    child: child,
  );
}