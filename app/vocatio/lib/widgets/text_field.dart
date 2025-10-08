import 'package:flutter/material.dart';

Widget TextFieldDesign({
  required TextEditingController controller,
  required String hintText,
  required BuildContext context,
}){
  final theme = Theme.of(context);
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 400),
    child: TextField(
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.surface
      ),
        filled: true,
        fillColor: theme.colorScheme.onSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none
        )
      ),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.surface
      ),
      controller: controller,
    ),
  );
}