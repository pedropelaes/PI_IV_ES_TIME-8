import 'package:flutter/material.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';

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

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      !isLargeScreen ?
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/images/logo_vocatio_pequena_transparente.png',
                          width: 100 ,
                          height: 100 ,
                          color: theme.colorScheme.onPrimary
                        ),
                      )
                      : ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 200, maxWidth: 400),
                          child: Image.asset('assets/images/logo_vocatio_transparente.png', fit: BoxFit.contain,)
                        ),
                      SizedBox(height: largeSpacing),
                
                      // Campo de nome da turma
                      TextFieldDesign(controller: nameController, hintText: 'Digite o nome da turma', context: context),
                      SizedBox(height: smallSpacing),
                
                      TextFieldDesign(controller: nameController, hintText: 'Descrição (opcional)', context: context),
                      SizedBox(height: largeSpacing),
                
                      // Botão Criar
                      primaryButtonDesign(
                        context: context,
                        label: 'Criar Turma',
                        width: 255,
                        height: 55.0,
                        onTap: () {
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
