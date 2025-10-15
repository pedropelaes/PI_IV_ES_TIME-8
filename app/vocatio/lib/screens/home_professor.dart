import 'package:flutter/material.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/custom_fab.dart';
import 'package:vocattio/widgets/turma_card.dart';
import 'package:vocattio/screens/detalhes_turma.dart';
import 'package:vocattio/utils/responsive_helper.dart';

class HomeProfessorScreen extends StatefulWidget {
  const HomeProfessorScreen({super.key});

  @override
  State<HomeProfessorScreen> createState() => _HomeProfessorScreenState();
}

class _HomeProfessorScreenState extends State<HomeProfessorScreen> {
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
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getMaxWidth(context),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saudação
                  Text(
                    'Olá, (NOME)',
                    style: textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Grid de turmas
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 1.0 : 0.85,
                      ),
                      itemCount: turmas.length,
                      itemBuilder: (context, index) {
                        final turma = turmas[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalhesTurmaScreen(
                                  nomeTurma: turma['nome'],
                                  descricao: turma['descricao'],
                                  numeroAlunos: turma['alunos'],
                                ),
                              ),
                            );
                          },
                          child: TurmaCard(
                            nomeTurma: turma['nome'],
                            descricao: turma['descricao'],
                            numeroAlunos: turma['alunos'],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: const CustomFAB(),
    );
  }
}
