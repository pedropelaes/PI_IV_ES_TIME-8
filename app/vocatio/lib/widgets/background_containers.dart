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
        stops: [0.62, 1.0],
        begin: horizontal ? Alignment.centerLeft : Alignment.topCenter,
        end: horizontal ? Alignment.centerRight : Alignment.bottomCenter
      )
    ),
    child: child,
  );
}


Widget primaryFormsContainer({
  required ThemeData theme,
  required Widget child
}){
  return Container(
    decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
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