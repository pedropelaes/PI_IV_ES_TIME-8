import 'package:flutter/material.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';

class CriarTurmaScreen extends StatelessWidget {
  const CriarTurmaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Controllers para capturar o nome e a descrição da turma
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Nova Turma',
        hasGoBack: true,
        onGoBack: () => Navigator.pop(context),
        onMenuPressed: () {},
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isLargeScreen = constraints.maxWidth > 700;
              double screenHeight = constraints.maxHeight;
              double scale = (screenHeight / 700).clamp(1.0, 1.5);
              double smallSpacing = (screenHeight * 0.015 * scale).clamp(6, 28);
              double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);

              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone central
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(
                        'assets/images/logo_vocatio_pequena_transparente.png',
                        width: isLargeScreen ? 200 : 100,
                        height: isLargeScreen ? 200 : 100,
                        color: theme.colorScheme.onPrimary
                      ),
                    ),
                    SizedBox(height: largeSpacing),
              
                    // Campo de nome da turma
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Digite o nome da turma',
                        filled: true,
                        fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: smallSpacing),
              
                    // Descrição
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Descrição (Opcional)',
                        filled: true,
                        fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: largeSpacing),
              
                    // Botão Criar
                    primaryButtonDesign(
                      context: context,
                      label: 'Criar Turma',
                      width: double.infinity,
                      height: 55.0,
                      onTap: () {
                      },
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
