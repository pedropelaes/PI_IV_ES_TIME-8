import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final bool hasGoBack;
  final VoidCallback? onGoBack; 

  const AppHeader({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.hasGoBack = false,
    this.onGoBack
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      leadingWidth: 100,
      leading: Row(
        children: [
          if (hasGoBack) 
            IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: onGoBack,
          ),
          IconButton(
            icon: Icon(
              Icons.menu,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: onMenuPressed,
          ),
        ],
      ),
      title: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16.0),
          child: Image.asset(
            'assets/images/logo_vocatio_pequena_transparente.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
