import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;

  const CustomFAB({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4,
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}
