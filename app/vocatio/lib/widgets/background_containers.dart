import 'package:flutter/material.dart';

Widget surfaceGradientHorizontalContainer({
   required BuildContext context,
   required Widget child
  })
  {
  final ThemeData theme = Theme.of(context);
  return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(
        colors: [theme.colorScheme.surface, theme.colorScheme.surfaceBright],
        stops: [0.62, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight
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
