import 'package:flutter/material.dart';
import 'package:vocatio/utils/responsive_helper.dart';

class AppDrawer extends StatelessWidget {
  final List<String> turmas;

  const AppDrawer({
    super.key,
    this.turmas = const ['Turma 1', 'Turma 2', 'Turma 3', 'Turma 4', 'Turma 5', 'Turma 6'],
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = ResponsiveHelper.isDesktop(context) 
        ? screenWidth * 0.3 
        : ResponsiveHelper.isTablet(context) 
            ? screenWidth * 0.4 
            : screenWidth * 0.5;

    return Drawer(
      width: drawerWidth,
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          // Logo no topo
          Container(
            height: 120,
            width: double.infinity,
            child: Center(
              child: Image.asset(
                'assets/images/logo_vocatio_pequena_transparente.png',
                height: 60,
                width: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Item Início
          ListTile(
            leading: Icon(
              Icons.home,
              color: theme.colorScheme.onSurface,
            ),
            title: Text(
              'Início',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navegar para a tela principal
            },
          ),
          
          const Divider(),
          
          // Seção Turmas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Turmas',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Lista de turmas
          Expanded(
            child: ListView.builder(
              itemCount: turmas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    Icons.class_,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    turmas[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Navegar para a turma específica
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
