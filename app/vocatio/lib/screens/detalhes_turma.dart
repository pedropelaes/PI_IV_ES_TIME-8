import 'package:flutter/material.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/screens/alunos_turma_screen.dart';
import 'package:vocattio/screens/tela_presencas.dart';
import 'package:vocattio/screens/gerar_qrcode_screen.dart';
import 'package:vocattio/screens/validate_attendance_screen.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/dialog_exc.dart';
import 'package:vocattio/widgets/animated_button.dart';
import 'package:vocattio/utils/responsive_helper.dart';
import 'package:vocattio/widgets/snackbars.dart';
import 'package:vocattio/widgets/app_drawer.dart'; 

class DetalhesTurmaScreen extends StatefulWidget {
  final String nomeTurma;
  final String descricao;
  final int numeroAlunos;
  final String codigoTurma;
  final String turmaId;
  final User user;

  const DetalhesTurmaScreen({
    super.key,
    required this.nomeTurma,
    required this.descricao,
    required this.numeroAlunos,
    required this.codigoTurma,
    required this.turmaId,
    required this.user,
  });

  @override
  State<DetalhesTurmaScreen> createState() => _DetalhesTurmaScreenState();
}

class _DetalhesTurmaScreenState extends State<DetalhesTurmaScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey, 
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Registrar',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer(); 
        },
        hasGoBack: true,
        onGoBack: () {
          Navigator.pop(context);
        },
      ),
      drawer: const AppDrawer(), 
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.isDesktop(context) ? 600 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Código da turma
                  primaryFixedGradientContainer(
                    width: double.infinity,
                    padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 24 : 20),
                    theme: theme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Código da Turma',
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primaryFixed,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.codigoTurma,
                          style: textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primaryFixed,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.descricao,
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primaryFixed.withValues(alpha: 0.9),
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? 50 : 40),
                  
                  // Botões de ação
                  Expanded(
                    child: ListView(
                      children: [

                        widget.user.tipo == 'professor' ? AnimatedButton(
                          text: 'Realizar chamada',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GerarQRCodeScreen(
                                  // Para abrir chamada no backend, usa-se o ObjectId da turma
                                  codigoTurma: widget.turmaId,
                                ),
                              ),
                            );
                          },
                        )
                        : AnimatedButton(
                          text: 'Registrar Presença',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ValidateAttendanceScreen(uid: widget.user.uid),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        AnimatedButton(
                          text: 'Ver Presenças',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PresencasScreen(
                                  nomeTurma: widget.nomeTurma,
                                  turmaId: widget.turmaId,
                                  userType: widget.user.tipo,
                                  userId: widget.user.objectId!,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if(widget.user.tipo == 'professor') AnimatedButton(
                          text: 'Exportar Lista de Presença',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de exportação será implementada'),
                              ),
                            );
                          },
                        ),
                        
                        if(widget.user.tipo == 'professor') const SizedBox(height: 16),
                        
                        if(widget.user.tipo == 'professor') AnimatedButton(
                          text: 'Relatório Mensal',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de relatório será implementada'),
                              ),
                            );
                          },
                        ),
                        
                        if(widget.user.tipo == 'professor') const SizedBox(height: 16),
                        
                        AnimatedButton(
                          text: 'Alunos',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlunosTurmaScreen(
                                  nomeTurma: widget.nomeTurma, 
                                  turmaId: widget.turmaId
                                )
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: widget.user.tipo == 'professor'
          ? FloatingActionButton(
              backgroundColor: theme.colorScheme.error,
              child: const Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                final confirm = await showCustomDialog(
                  context,
                  Icons.delete_forever,
                  'Deseja apagar essa turma?',
                  'Não será possível restaurar essa turma, deve ter certeza que deseja excluir permanentemente.',
                  () {
                    // logica de apagar turma (a ser implementada)
                  },
                  'Apagar',
                  isCritical: true,
                );

                if (confirm == true) {
                  showSuccessSnackBar('Turma excluída com sucesso!', context);
                  Navigator.pop(context); 
                }
              },
            )
          : FloatingActionButton(
              // Botão para o ALUNO: Sair da Turma
              backgroundColor: theme.colorScheme.tertiary,
              child: const Icon(Icons.exit_to_app, color: Colors.white), 
              onPressed: () async {
                final confirm = await showCustomDialog(
                  context,
                  Icons.exit_to_app,
                  'Deseja sair da turma?',
                  'Você precisará do código para entrar novamente. Confirma a saída?',
                  () {
                    // logica de sair da turma (a ser implementada)
                  },
                  'Sair',
                  isCritical: true,
                );

                if (confirm == true) {
                  showSuccessSnackBar('Você saiu da turma ${widget.nomeTurma}', context);
                  Navigator.pop(context); 
                }
              },
            ),
    );
  }
}