import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:vocattio/utils/responsive_helper.dart';

class AppDrawer extends StatelessWidget {
  final List<String> turmas;

  const AppDrawer({
    super.key,
    this.turmas = const [],
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
          
          ListTile(
            leading: Icon(
              Icons.settings, 
              color: theme.colorScheme.secondary,
            ),
            title: Text(
              'Configurações',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Lógica de navegação para a tela de configurações
              print('Navegar para Configurações');
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
          
          // Lista de turmas (usa a lista passada)
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
                    turmas[index], // Usa o nome da turma
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Lógica para navegar para a turma específica (você pode precisar do ID aqui)
                  },
                );
              },
            ),
          ),

          const Divider(), 
          
          ListTile(
            leading: Icon(
              Icons.logout,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Sair',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Phoenix.rebirth(context);
              print('Usuário deslogado!'); 
            },
          ),
          
          SizedBox(height: 16),
        ],
      ),
    );
  }
}