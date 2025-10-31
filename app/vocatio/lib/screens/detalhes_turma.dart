import 'package:flutter/material.dart';
import 'package:vocattio/screens/tela_presencas.dart';
import 'package:vocattio/screens/gerar_qrcode_screen.dart';
import 'package:vocattio/screens/validate_attendance_screen.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/dialog_exc.dart';
import 'package:vocattio/widgets/animated_button.dart';
import 'package:vocattio/utils/responsive_helper.dart';
import 'package:vocattio/widgets/snackbars.dart';

class DetalhesTurmaScreen extends StatefulWidget {
  final String tipoUsuario;
  final String nomeTurma;
  final String descricao;
  final int numeroAlunos;
  final String codigoTurma;
  final String turmaId;
  final String? uid;

  const DetalhesTurmaScreen({
    super.key,
    required this.tipoUsuario,
    required this.nomeTurma,
    required this.descricao,
    required this.numeroAlunos,
    required this.codigoTurma,
    required this.turmaId,
    this.uid,
  });

  @override
  State<DetalhesTurmaScreen> createState() => _DetalhesTurmaScreenState();
}

class _DetalhesTurmaScreenState extends State<DetalhesTurmaScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Registrar',
        onMenuPressed: () {
        },
        hasGoBack: true,
        onGoBack: () {
          Navigator.pop(context);
        },
      ),
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

                        widget.tipoUsuario == 'professor' ? AnimatedButton(
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
                                builder: (context) => ValidateAttendanceScreen(uid: widget.uid),
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
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if(widget.tipoUsuario == 'professor') AnimatedButton(
                          text: 'Exportar Lista de Presença',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de exportação será implementada'),
                              ),
                            );
                          },
                        ),
                        
                        if(widget.tipoUsuario == 'professor') const SizedBox(height: 16),
                        
                        if(widget.tipoUsuario == 'professor') AnimatedButton(
                          text: 'Relatório Mensal',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de relatório será implementada'),
                              ),
                            );
                          },
                        ),
                        
                        if(widget.tipoUsuario == 'professor') const SizedBox(height: 16),
                        
                        AnimatedButton(
                          text: 'Alunos',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de alunos será implementada'),
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
      floatingActionButton: widget.tipoUsuario == 'professor' ? FloatingActionButton(
        backgroundColor: const Color(0xFF9B71D9),
        child: const Icon(Icons.delete, color: Colors.white),
        onPressed: () async {
          final confirm = await showCustomDialog(
            context, 
            Icons.delete_forever,
            'Deseja apagar essa turma?',
            'Não será possível restaurar essa turma, deve ter certeza que deseja excluir permanentemente.',
            (){
              // logica de apagar
            },
            'Apagar',
            isCritical: true,
          );

          if (confirm == true) {
            showSuccessSnackBar('Turma excluída com sucesso!', context);
            Navigator.pop(context);
          }
        },
      )  : null
    );
  }
}