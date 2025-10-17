import 'package:flutter/material.dart';
import 'package:vocattio/screens/tela_presencas.dart';
import 'package:vocattio/screens/gerar_qrcode_screen.dart';
import 'package:vocattio/widgets/dialog_exc.dart';
import 'package:vocattio/widgets/animated_button.dart';
import 'package:vocattio/utils/responsive_helper.dart';

class DetalhesTurmaScreen extends StatefulWidget {
  final String nomeTurma;
  final String descricao;
  final int numeroAlunos;

  const DetalhesTurmaScreen({
    super.key,
    required this.nomeTurma,
    required this.descricao,
    required this.numeroAlunos,
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
          widget.nomeTurma,
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
              maxWidth: ResponsiveHelper.isDesktop(context) ? 600 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Código da turma
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 24 : 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF523C73),
                          Color(0xFF9B71D9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Código da Turma',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'TURMA001', // Código fixo por enquanto
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.descricao,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? 50 : 40),
                  
                  // Botões de ação
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedButton(
                          text: 'Gerar QR CODE',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GerarQRCodeScreen(
                                  codigoTurma: 'TURMA001',
                                ),
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
                                builder: (context) => const PresencasScreen(),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        AnimatedButton(
                          text: 'Exportar Lista de Presença',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de exportação será implementada'),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        AnimatedButton(
                          text: 'Relatório Mensal',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de relatório será implementada'),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
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
      floatingActionButton: FloatingActionButton(
  backgroundColor: const Color(0xFF9B71D9),
  child: const Icon(Icons.delete, color: Colors.white),
  onPressed: () async {
    final confirm = await showDeleteDialog(context, (){});

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turma excluída com sucesso!'),
        ),
      );
      Navigator.pop(context);
    }
  },
),
    );
  }
}