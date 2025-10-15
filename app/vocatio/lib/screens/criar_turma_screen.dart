import 'package:flutter/material.dart';
import 'package:vocattio/widgets/text_field.dart';
import 'package:vocattio/widgets/animated_button.dart';
import 'package:vocattio/utils/responsive_helper.dart';

class CriarTurmaScreen extends StatefulWidget {
  const CriarTurmaScreen({super.key});

  @override
  State<CriarTurmaScreen> createState() => _CriarTurmaScreenState();
}

class _CriarTurmaScreenState extends State<CriarTurmaScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1A20),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Criar Nova Turma',
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.isDesktop(context) ? 500 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo centralizada
                  Center(
                    child: Image.asset(
                      'assets/images/logo_vocatio_pequena_transparente.png',
                      height: ResponsiveHelper.isDesktop(context) ? 100 : 80,
                      width: ResponsiveHelper.isDesktop(context) ? 100 : 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Input Nome da Turma
                  TextFieldDesign(
                    controller: nomeController,
                    hintText: 'Nome da Turma',
                    context: context,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Input Descrição
                  TextFieldDesign(
                    controller: descricaoController,
                    hintText: 'Descrição',
                    context: context,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botão Criar
                  AnimatedButton(
                    text: 'Criar',
                    backgroundColor: const Color(0xFFD5BBFC),
                    textColor: Colors.black,
                    borderRadius: 8,
                    onPressed: () {
                      // Lógica para criar turma
                      if (nomeController.text.isNotEmpty && descricaoController.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Turma criada com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, preencha todos os campos'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}