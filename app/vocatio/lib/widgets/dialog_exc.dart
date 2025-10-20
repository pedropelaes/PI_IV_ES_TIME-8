import 'package:flutter/material.dart';
import 'package:vocattio/widgets/background_containers.dart';

Future<bool?> showCustomDialog(BuildContext context, String title, String body, VoidCallback apagar, String actionLabel, {bool isCritical = false}) async {
 
  final ThemeData theme = Theme.of(context);

  return showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400.0),
          child: primaryFixedGradientContainer(
            theme: theme,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_forever,
                  color: theme.colorScheme.primaryFixed,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primaryFixedDim,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primaryFixed,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancelar',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primaryFixedDim
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                        apagar(); 
                      },
                  
                      child: Text(
                        actionLabel,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isCritical ? theme.colorScheme.error : theme.colorScheme.primaryFixedDim,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}