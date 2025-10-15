import 'package:flutter/material.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/custom_fab.dart';
import 'package:vocattio/widgets/button_class_student.dart';

class HomeStudentScreen extends StatefulWidget {
  const HomeStudentScreen({super.key});
  
  @override
  State<HomeStudentScreen> createState() => _HomeStudentScreenState();
}

class _HomeStudentScreenState extends State<HomeStudentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Dados das turmas baseados na imagem
  final List<Map<String, dynamic>> turmas = [
    {'nome': 'Turma 1', 'descricao': 'Descrição *', 'alunos': 32},
    {'nome': 'Turma 2', 'descricao': 'Descrição *', 'alunos': 51},
    {'nome': 'Turma 3', 'descricao': 'Descrição *', 'alunos': 17},
    {'nome': 'Turma 4', 'descricao': 'Descrição *', 'alunos': 30},
    {'nome': 'Turma 5', 'descricao': 'Descrição *', 'alunos': 42},
    {'nome': 'Turma 6', 'descricao': 'Descrição *', 'alunos': 0},
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Turmas',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saudação
              Text(
                'Olá, (NOME)',
                style: textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              
              // Grid de turmas
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: turmas.length,
                  itemBuilder: (context, index) {
                    final turma = turmas[index];
                    return ButtonClassStudent(
                      nomeTurma: turma['nome'],
                      descricao: turma['descricao'],
                      numeroAlunos: turma['alunos'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomFAB(
        onPressed: () {
          final TextEditingController codigoController = TextEditingController();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Entrar em uma turma'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Digite o código da turma para entrar:'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código da turma',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final codigo = codigoController.text.trim();

                    if (codigo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Digite um código válido')),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Código digitado: $codigo')),
                    );

                    // aqui você pode adicionar a lógica para validar o código
                    // e adicionar o aluno à turma correspondente
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          );
        },
      ),

    );
  }
}
