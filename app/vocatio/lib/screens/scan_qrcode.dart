import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vocattio/services/auth_service.dart';
import 'package:vocattio/services/location/location_service.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/snackbars.dart';
import 'package:vocattio/widgets/text_field.dart';

class ScanQrcode extends StatefulWidget {
  const ScanQrcode({super.key});

  @override
  State<ScanQrcode> createState() => _ScanQrcodeState();
}

class _ScanQrcodeState extends State<ScanQrcode> {
  final TextEditingController _codeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  final _locationService = LocationService();
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
    _locationService.checkLocationPermission();
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    print('=== INICIANDO OBTENÇÃO DE LOCALIZAÇÃO ===');
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // PASSO 1: Verificar permissões primeiro
      print('PASSO 1: Verificando permissões...');
      bool hasPermission = await _locationService.checkLocationPermission();
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
        if(mounted) {
          _locationService.showPermissionDialog(
            context,
            'Serviços de Localização Desabilitados',
            'Os serviços de localização estão desabilitados. Por favor, habilite-os nas configurações do dispositivo.',
            'Ir para Configurações',
            () async {
              await Geolocator.openLocationSettings();
            },
          );
        }
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

      if(mounted) showSuccessSnackBar('Localização obtida com sucesso!', context);
      

    } catch (e) {
      print('ERRO ao obter localização: $e');
      setState(() {
        _isGettingLocation = false;
      });

      String errorMessage = 'Erro ao obter localização.';
      
      if (e.toString().contains('timeout')) {
        errorMessage = ' Timeout: GPS pode estar desabilitado ou em ambiente fechado.';
      } else if (e.toString().contains('permission')) {
        errorMessage = ' Permissão de localização necessária.';
      } else if (e.toString().contains('location')) {
        errorMessage = ' Não foi possível determinar sua localização.';
      }

      if(mounted) showErrorSnackBar(errorMessage, context);

    }
  }

  Future<bool> _registrarPresenca({required String aulaId, required String alunoId}) async {
  final socket = getIt<SocketService>();

  final jsonRegistrar = {
    "operacao": "RegistrarPresenca",
    "aulaId": aulaId,
    "alunoId": AuthService.currentUser.id, // o id do aluno logado
    if (_currentLocation != null) "latitude": _currentLocation!.latitude,
    if (_currentLocation != null) "longitude": _currentLocation!.longitude,
  };

  socket.send(jsonRegistrar);

  try {
    final responseData = await socket.messages.firstWhere((data) {
      try {
        final message = jsonDecode(data is String ? data : utf8.decode(data));
        return message['operacao'] == 'ResultadoRegistrarPresenca';
      } catch (_) {
        return false;
      }
    }).timeout(const Duration(seconds: 10));

    final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));

    if (responseJson['resultado'] == true) {
      if (mounted) {
        showSuccessSnackBar("Presença registrada com sucesso!", context);
      }
      return true;
    } else {
      if (mounted) {
        showErrorSnackBar("Erro: ${responseJson['mensagem']}", context);
      }
      return false;
    }
  } catch (e) {
    if (mounted) {
      showErrorSnackBar("Erro ao registrar presença: $e", context);
    }
    return false;
  }
}


  bool get hasScanner =>
    kIsWeb || Platform.isAndroid || Platform.isIOS;

  // Método para lidar com a conclusão da chamada
  Future<void> _handleCompleteAttendance() async {
    // Primeiro obtém a localização
    await _getCurrentLocation();
    
    if (_codeController.text.isEmpty) {
      if(mounted) showErrorSnackBar('Por favor, escaneie um QR Code primeiro.', context);
      return;
    }

    if (_currentLocation == null) {
      if(mounted) showErrorSnackBar('Não foi possível obter sua localização.', context);
      return;
    }

    // A validação de geofence é feita no servidor (100m).

      final alunoId = AuthService.currentUser.id;
      final resultado = await _registrarPresenca(
        aulaId: _codeController.text,
        alunoId: alunoId,
      );

      if (!resultado) {
        if (mounted) showErrorSnackBar("Erro ao registrar presença.", context);
        return;
      }

      if (mounted) {
        showSuccessSnackBar(
          'Chamada concluída!\n'
          'QR Code: ${_codeController.text}\n'
          'Localização: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}',
          context,
        );
      }
      Navigator.pop(context);
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
                          showSuccessSnackBar('QR Code lido: $barcode', context);
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
