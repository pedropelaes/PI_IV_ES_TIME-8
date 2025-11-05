import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vocattio/services/location/location_service.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/animated_button.dart';
import 'package:vocattio/utils/responsive_helper.dart';
import 'package:vocattio/widgets/snackbars.dart';

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
  final _locationService = LocationService();
  Position? _profLocation;
  Timer? _timer;
  int _tempoRestante = 60; // 1 minuto
  bool _chamadaFechada = false;

  @override
  void initState() {
    super.initState();
    _gerarChamada(); // assim que a tela abre, já pede o QR Code
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fecharChamada(); // fecha chamada caso professor saia da tela
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
                    
                    // Indicador de tempo restante
                    if (codigoChamada != null && !_chamadaFechada)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: _tempoRestante <= 10 ? Colors.red.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _tempoRestante <= 10 ? Colors.red : Colors.orange,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer,
                              color: _tempoRestante <= 10 ? Colors.red : Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tempo restante: ${_tempoRestante}s',
                              style: textTheme.titleMedium?.copyWith(
                                color: _tempoRestante <= 10 ? Colors.red : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
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
                            : codigoChamada != null && !_chamadaFechada
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
                                : codigoChamada != null && _chamadaFechada
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 100,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Chamada encerrada',
                                            style: textTheme.titleLarge?.copyWith(
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.bold,
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
                    
                    // Box do código da chamada
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
                            'Código da Chamada',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            codigoChamada ?? 'Gerando... ',
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
                      text: _chamadaFechada ? 'Voltar' : 'Concluir Chamada',
                      backgroundColor: _chamadaFechada ? Colors.grey : const Color(0xFFD5BBFC),
                      textColor: _chamadaFechada ? Colors.white : const Color(0xFF3A255B),
                      borderRadius: 12,
                      onPressed: _chamadaFechada
                          ? () {
                              Navigator.pop(context);
                            }
                          : () {
                              _fecharChamada();
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

  // Obtém localização do professor automaticamente
  try {
    bool hasPermission = await _locationService.checkLocationPermission();
    if (!hasPermission) throw Exception('Permissão de localização negada');
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    _profLocation = position;
  } catch (e) {
    if (mounted) {
      showErrorSnackBar('Não foi possível obter a sua localização atual. A localização da turma será usada no lugar.', context);
    }
  }

  final jsonGerarChamada = {
    "operacao": "AbrirChamada",
    "codigoTurma": widget.codigoTurma,
    "latitude": _profLocation?.latitude ?? 0,
    "longitude": _profLocation?.longitude ?? 0,
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
        _iniciarTimer();
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

void _iniciarTimer() {
  _tempoRestante = 300;
  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (mounted) {
      setState(() {
        if (_tempoRestante > 0) {
          _tempoRestante--;
        } else {
          timer.cancel();
          _fecharChamadaAutomaticamente();
        }
      });
    } else {
      timer.cancel();
    }
  });
}

Future<void> _fecharChamadaAutomaticamente() async {
  if (_chamadaFechada) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Tempo esgotado! Chamada encerrada automaticamente.'),
      backgroundColor: Colors.orange,
      duration: Duration(seconds: 2),
    ),
  );
  
  await _fecharChamada();
  
  // Aguarda 2 segundos e retorna para a home
  await Future.delayed(const Duration(seconds: 2));
  if (mounted) {
    Navigator.pop(context);
  }
}

Future<void> _fecharChamada() async {
  if (codigoChamada == null || _chamadaFechada) return;
  
  _timer?.cancel();
  
  final jsonFecharChamada = {
    "operacao": "FecharChamada",
    "codigoChamada": codigoChamada,
  };
  
  print('Enviando FecharChamada: $jsonFecharChamada');
  
  try {
    _socketService.send(jsonFecharChamada);
    print('Mensagem enviada. Aguardando resposta...');
    
    final responseData = await _socketService.messages.firstWhere((data) {
      try {
        final message = jsonDecode(data is String ? data : utf8.decode(data));
        return message['operacao'] == 'ResultadoFecharChamada';
      } catch (e) {
        return false;
      }
    }).timeout(const Duration(seconds: 10));
    
    final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));
    print('Resposta recebida: $responseJson');
    
    if (responseJson['resultado'] == true) {
      if (mounted) {
        setState(() {
          _chamadaFechada = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chamada encerrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao encerrar chamada.")),
        );
      }
    }
  } on TimeoutException {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tempo de resposta esgotado ao encerrar.")),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao encerrar chamada: $e")),
      );
    }
  }
}
}