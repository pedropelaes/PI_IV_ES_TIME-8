import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';

class ScanQrcode extends StatefulWidget {
  const ScanQrcode({super.key});

  @override
  State<ScanQrcode> createState() => _ScanQrcodeState();
}

class _ScanQrcodeState extends State<ScanQrcode> {
  final TextEditingController _codeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _scanned = false;
  Position? _currentLocation;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _scannerController.dispose(); 
    _codeController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _checkLocationPermission();
  }

  bool get hasScanner =>
    kIsWeb || Platform.isAndroid || Platform.isIOS;



  Future<bool> _checkLocationPermission() async {
    // Passo 1: Verifica permissão atual
    LocationPermission geoPermission = await Geolocator.checkPermission();

    // Passo 2: Solicita "When in Use" se ainda não tiver
    if (geoPermission == LocationPermission.denied ||
        geoPermission == LocationPermission.deniedForever) {
      geoPermission = await Geolocator.requestPermission();
    }

    // Passo 3: Se for iOS e já tiver "When in Use", tenta pedir "Always"
    if (Platform.isIOS && geoPermission == LocationPermission.whileInUse) {
      // Esse segundo pedido dispara o popup "Permitir sempre"
      geoPermission = await Geolocator.requestPermission();
    }

    // Passo 4: Confere resultado final
    if (geoPermission == LocationPermission.always ||
      geoPermission == LocationPermission.whileInUse) {
      print("Permissão de localização concedida: $geoPermission");
      return true;
    } else {
      print("Permissão de localização negada: $geoPermission");
      return false;
    }
  }


  // Mostrar diálogo de permissão
  void _showPermissionDialog(String title, String message, String buttonText, VoidCallback onPressed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onPressed();
              },
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  // Obter localização atual
  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    print('=== INICIANDO OBTENÇÃO DE LOCALIZAÇÃO ===');
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // PASSO 1: Verificar permissões primeiro
      print('PASSO 1: Verificando permissões...');
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        print('Permissões não concedidas, abortando...');
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // PASSO 2: Verificar serviços de localização
      print('PASSO 2: Verificando serviços de localização...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Serviços de localização desabilitados');
        _showPermissionDialog(
          'Serviços de Localização Desabilitados',
          'Os serviços de localização estão desabilitados. Por favor, habilite-os nas configurações do dispositivo.',
          'Ir para Configurações',
          () async {
            await Geolocator.openLocationSettings();
          },
        );
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // PASSO 3: Obter localização
      print('PASSO 3: Obtendo posição atual...');
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        timeLimit: const Duration(seconds: 20),
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      print('SUCESSO: Localização obtida - Lat: ${position.latitude}, Lng: ${position.longitude}');
      setState(() {
        _currentLocation = position;
        _isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Localização obtida com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      print('ERRO ao obter localização: $e');
      setState(() {
        _isGettingLocation = false;
      });

      String errorMessage = 'Erro ao obter localização.';
      
      if (e.toString().contains('timeout')) {
        errorMessage = '⏰ Timeout: GPS pode estar desabilitado ou em ambiente fechado.';
      } else if (e.toString().contains('permission')) {
        errorMessage = '🚫 Permissão de localização necessária.';
      } else if (e.toString().contains('location')) {
        errorMessage = '📍 Não foi possível determinar sua localização.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Método para lidar com a conclusão da chamada
  Future<void> _handleCompleteAttendance() async {
    // Primeiro obtém a localização
    await _getCurrentLocation();
    
   
    if (_currentLocation != null && _codeController.text.isNotEmpty) {
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Chamada concluída!\n'
            'QR Code: ${_codeController.text}\n'
            'Localização: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}'
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      
      // Voltar para a tela anterior
      Navigator.pop(context);
    } else if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, escaneie um QR Code primeiro.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Método para testar permissões de forma detalhada
  Future<void> _testPermissions() async {
    print('=== TESTE DE PERMISSÕES ===');
    
    try {
      // Verificar status atual
      PermissionStatus status = await Permission.location.status;
      print('Status atual: $status');
      
      // Verificar se serviços estão habilitados
      bool servicesEnabled = await Geolocator.isLocationServiceEnabled();
      print('Serviços habilitados: $servicesEnabled');
      
      String message = '';
      Color backgroundColor = Colors.blue;
      
      if (!servicesEnabled) {
        message = ' Serviços de localização estão DESABILITADOS';
        backgroundColor = Colors.orange;
      } else if (status.isGranted) {
        message = ' Permissões de localização estão OK!';
        backgroundColor = Colors.green;
      } else if (status.isDenied) {
        message = ' Permissão negada. Clique para solicitar.';
        backgroundColor = Colors.orange;
      } else if (status.isPermanentlyDenied) {
        message = ' Permissão negada permanentemente. Vá para configurações.';
        backgroundColor = Colors.red;
      } else {
        message = '❓ Status desconhecido: $status';
        backgroundColor = Colors.grey;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
      
      // Se permissão foi negada, tentar solicitar
      if (status.isDenied) {
        await Future.delayed(const Duration(seconds: 2));
        await _checkLocationPermission();
      }
      
    } catch (e) {
      print('Erro no teste de permissões: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao testar permissões: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
      body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Título principal
                    Text(
                      'Aponte a câmera para o QR Code',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Área da câmera
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: hasScanner ? MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) {
                          if (_scanned) return;
                          _scanned = true;
                          final barcode = capture.barcodes.first.rawValue ?? '';
                          setState(() => _codeController.text = barcode);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('QR Code lido: $barcode'),
                              backgroundColor: theme.colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ) : Row()
                    ),
                
                    const SizedBox(height: 16),
                
                    TextFieldDesign(
                      controller: _codeController, 
                      hintText: 'Digite o código temporário', 
                      context: context
                    ),
                
                    const SizedBox(height: 24),
                
                    // Indicador de localização
                    if (_currentLocation != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Localização obtida:',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    'Lat: ${_currentLocation!.latitude.toStringAsFixed(4)}, Lng: ${_currentLocation!.longitude.toStringAsFixed(4)}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                
                    const SizedBox(height: 16),
                
                    // Botão para testar permissões
                    TextButton(
                      onPressed: () async {
                        await _testPermissions();
                      },
                      child: Text(
                        '🔍 Testar Permissões de Localização',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 24),
                
                    primaryButtonDesign(
                      context: context,
                      label: _isGettingLocation ? 'Obtendo localização...' : 'Concluir chamada',
                      width: double.infinity,
                      height: 55.0,
                      onTap: _isGettingLocation ? () {} : () {
                        _handleCompleteAttendance();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
      