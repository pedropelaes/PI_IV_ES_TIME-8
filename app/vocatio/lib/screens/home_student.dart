import 'package:flutter/material.dart';
import 'package:vocatio/widgets/button_class_student.dart';

class HomeStudentScreen extends StatefulWidget {
  const HomeStudentScreen({super.key});

  @override
  State<HomeStudentScreen> createState() => _HomeStudentScreenState();
}

class _HomeStudentScreenState extends State<HomeStudentScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    'Turmas',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 30),

                  // Grade com 2 colunas de botões quadrados
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        TurmaButton(
                          nomeTurma: 'Turma A',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Clicou em Turma A')),
                            );
                          },
                        ),
                        TurmaButton(
                          nomeTurma: 'Turma B',
                          subtitulo: 'PPOO',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Clicou em Turma B')),
                            );
                          },
                        ),
                        TurmaButton(
                          nomeTurma: 'Turma C',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Clicou em Turma C')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Botão de adicionar turma flutuante no canto inferior direito
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildAddTurmaButton(() {
                final TextEditingController codigoController = TextEditingController();

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Nova Turma'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min, // ajusta o tamanho ao conteúdo
                      children: [
                        const Text('Digite o código da nova turma:'),
                        const SizedBox(height: 10),
                        TextField(
                          controller: codigoController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Código da turma',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          final codigo = codigoController.text;
                          // aqui você pode salvar ou processar o código
                          print('Código digitado: $codigo');
                          Navigator.pop(context);
                        },
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }



  /// Botão flutuante de adicionar turma
  Widget _buildAddTurmaButton(VoidCallback onPressed) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.white24,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(Icons.add, color: theme.colorScheme.onPrimaryContainer, size: 30),
      ),
    );
  }
}
