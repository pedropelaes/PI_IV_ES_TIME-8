import 'package:flutter/material.dart';
import 'package:vocatio/widgets/animated_button.dart';
import 'package:vocatio/utils/responsive_helper.dart';

class GerarQRCodeScreen extends StatefulWidget {
  final String codigoTurma;

  const GerarQRCodeScreen({
    super.key,
    required this.codigoTurma,
  });

  @override
  State<GerarQRCodeScreen> createState() => _GerarQRCodeScreenState();
}

class _GerarQRCodeScreenState extends State<GerarQRCodeScreen> {
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
          'Chamada',
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
                children: [
                  const SizedBox(height: 40),
                  
                  // Box branco para simular a câmera
                  Container(
                    width: double.infinity,
                    height: ResponsiveHelper.isDesktop(context) ? 400 : 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: ResponsiveHelper.isDesktop(context) ? 100 : 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Visualização da Câmera',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'QR Code será exibido aqui',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Box do código da turma
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
                          widget.codigoTurma,
                          style: textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Apresente este código para os alunos',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Botão Concluir Chamada
                  AnimatedButton(
                    text: 'Concluir Chamada',
                    backgroundColor: const Color(0xFFD5BBFC),
                    textColor: const Color(0xFF3A255B),
                    borderRadius: 12,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chamada concluída com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}