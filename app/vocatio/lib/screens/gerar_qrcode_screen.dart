import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/animated_button.dart';
import 'package:vocattio/utils/responsive_helper.dart';

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
  final SocketService _socketService = getIt<SocketService>();
  String? codigoChamada; // o código/ID que vem do servidor
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    _gerarChamada(); // assim que a tela abre, já pede o QR Code
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
              child: SingleChildScrollView(
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
                      child: Center(
                        child: carregando
                            ? const CircularProgressIndicator()
                            : codigoChamada != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      QrImageView(
                                        data: codigoChamada!,
                                        version: QrVersions.auto,
                                        size: 200,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Escaneie para registrar presença',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.qr_code_scanner,
                                        size: ResponsiveHelper.isDesktop(context) ? 100 : 80,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'QR Code será exibido aqui',
                                        style: textTheme.titleMedium?.copyWith(
                                          color: Colors.grey.shade600,
                                          fontSize:
                                              ResponsiveHelper.getResponsiveFontSize(context, 18),
                                        ),
                                      ),
                                    ],
                                  ),
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
                    
                    SizedBox(height: ResponsiveHelper.isDesktop(context) ? 40 : 24),
                    
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
      ),
    );
  }
  
  Future<void> _gerarChamada() async {
  WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted) {
    setState(() => carregando = true);
  }
});

  Map<String, dynamic> jsonGerarChamada = {
    "operacao": "AbrirChamada",
    "codigoTurma": widget.codigoTurma,
  };

  try {
    _socketService.send(jsonGerarChamada);

    final responseData = await _socketService.messages.firstWhere((data) {
      try {
        final message = jsonDecode(data is String ? data : utf8.decode(data));
        return message['operacao'] == 'ResultadoAbrirChamada';
      } catch (e) {
        return false;
      }
    }).timeout(const Duration(seconds: 10));

    final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));

    if (responseJson['resultado'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          codigoChamada = responseJson['codigoChamada'];
        });
      }
    });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao gerar chamada.")),
      );
    }
  } on TimeoutException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tempo de resposta esgotado.")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro ao gerar chamada: $e")),
    );
  } finally {
    if (mounted) {
      setState(() => carregando = false);
    }
  }
}
}