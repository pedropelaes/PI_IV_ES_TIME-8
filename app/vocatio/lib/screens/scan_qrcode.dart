import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vocattio/mixins/attendance_handler.dart';
import 'package:vocattio/services/location/location_service.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/snackbars.dart';
import 'package:vocattio/widgets/text_field.dart';
import 'package:vocattio/models/user.dart';

class ScanQrcode extends StatefulWidget {
  final String? uid;
  
  const ScanQrcode({super.key, this.uid});

  @override
  State<ScanQrcode> createState() => _ScanQrcodeState();
}

class _ScanQrcodeState extends State<ScanQrcode> with AttendanceHandler {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _locationService = LocationService();
  bool _scanned = false;
  Position? _currentLocation;
  bool _isGettingLocation = false;
  User? _currentUser;

  @override
  void dispose() {
    _scannerController.dispose(); 
    _codeController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    //_locationService.checkLocationPermission();

    initUserSession();
  }


  bool get hasScanner =>
    kIsWeb || Platform.isAndroid || Platform.isIOS;

  // Método para lidar com a conclusão da chamada
  Future<void> _handleCompleteAttendance() async {
    // Primeiro obtém a localização
    final location = await getCurrentLocation();
    
    if (_codeController.text.isEmpty) {
      if(mounted) showErrorSnackBar('Por favor, escaneie um QR Code primeiro.', context);
      return;
    }

    if(_tempController.text.isEmpty){
      if(mounted) showErrorSnackBar('Por favor, digite o código temporário.', context);
      return;
    }

    if (_currentLocation == null) {
      if(mounted) showErrorSnackBar('Não foi possível obter sua localização.', context);
      return;
    }
    
    if(location == null) return;

    // A validação de geofence é feita no servidor

    final resultado = await registrarPresenca(
      aulaId: _codeController.text.trim(),
      codigoTemporario: _tempController.text.trim()
    );

    if (!resultado) {
      if (mounted) showErrorSnackBar("Erro ao registrar presença.", context);
      return;
    }

    if (resultado && mounted) {
      Navigator.pop(context);
    } 
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, 
      key: _scaffoldKey,
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
      drawer: AppDrawer(),
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
