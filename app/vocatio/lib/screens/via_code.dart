import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vocattio/services/location/location_service.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/snackbars.dart';
import 'package:vocattio/widgets/text_field.dart';
import 'dart:async';
import 'dart:convert';
import 'package:vocattio/services/auth_service.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/models/user.dart';

class ViaCode extends StatefulWidget {
  final String? uid;
  
  const ViaCode({super.key, this.uid});

  @override
  State<ViaCode> createState() => _ViaCodeState();
}

class _ViaCodeState extends State<ViaCode> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _tempCodeController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _locationService = LocationService();
  final AuthService _authService = AuthService();
  Position? _currentLocation;
  bool _isGettingLocation = false;
  final SocketService _socketService = getIt<SocketService>();
  User? _currentUser;

  @override
  void initState(){
    super.initState();
    _locationService.checkLocationPermission();
    if (widget.uid != null) {
      _carregarUsuario();
    }
  }

  Future<void> _carregarUsuario() async {
    try {
      final user = await _authService.getUser(widget.uid!);
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Erro ao carregar usuário: $e');
    }
  }

  @override
  void dispose() {
    _tempCodeController.dispose(); 
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    print('=== INICIANDO OBTENÇÃO DE LOCALIZAÇÃO ===');
    setState(() {
      _isGettingLocation = true;
    });

    try {
      print('PASSO 1: Verificando permissões...');
      bool hasPermission = await _locationService.checkLocationPermission();
      if (!hasPermission) {
        print('Permissões não concedidas, abortando...');
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

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
        errorMessage = 'Permissão de localização necessária.';
      } else if (e.toString().contains('location')) {
        errorMessage = 'Não foi possível determinar sua localização.';
      }

      if(mounted) showErrorSnackBar(errorMessage, context);

    }
  }

  // Método para lidar com a conclusão da chamada
  Future<void> _handleCompleteAttendance() async {
    // Verificar se os campos estão preenchidos
    if (_codeController.text.isEmpty || _tempCodeController.text.isEmpty) {
      if(mounted) showErrorSnackBar('Por favor, preencha todos os campos.', context);
      return;
    }

    // Obter a localização atual
    await _getCurrentLocation();

    if (_currentLocation == null) {
      if(mounted) showErrorSnackBar('Não foi possível obter sua localização.', context);
      return;
    }

    // Verifica se o usuário foi carregado
    if (_currentUser == null || _currentUser!.objectId == null) {
      if (mounted) {
        showErrorSnackBar('Erro: Usuário não identificado. Por favor, faça login novamente.', context);
      }
      return;
    }

    // Envia presença ao servidor; validação de 100m ocorre no backend
    final sucesso = await _registrarPresenca(
      aulaId: _codeController.text.trim(),
    );

    if (!sucesso) {
      if (mounted) showErrorSnackBar('Erro ao registrar presença.', context);
      return;
    }

    if(mounted){
      showSuccessSnackBar('Chamada concluída!\n'
        'Código: ${_codeController.text}\n'
        'Localização: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}', 
        context
      );  
      Navigator.pop(context);
    }
  }

  Future<bool> _registrarPresenca({required String aulaId}) async {
    // Verifica se o usuário foi carregado
    if (_currentUser == null || _currentUser!.objectId == null) {
      if (mounted) {
        showErrorSnackBar('Erro: Usuário não identificado. Por favor, faça login novamente.', context);
      }
      return false;
    }

    final payload = {
      "operacao": "RegistrarPresenca",
      // via código: usa o código textual da chamada
      "codigoChamada": aulaId,
      "alunoId": _currentUser!.objectId!,
      if (_currentLocation != null) "latitude": _currentLocation!.latitude,
      if (_currentLocation != null) "longitude": _currentLocation!.longitude,
    };

    _socketService.send(payload);

    try {
      final responseData = await _socketService.messages.firstWhere((data) {
        try {
          final message = jsonDecode(data is String ? data : utf8.decode(data));
          return message['operacao'] == 'ResultadoRegistrarPresenca';
        } catch (_) {
          return false;
        }
      }).timeout(const Duration(seconds: 10));

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));
      if (responseJson['resultado'] == true) return true;
      final msg = responseJson['mensagem'];
      if (mounted) showErrorSnackBar(msg ?? 'Erro ao registrar presença', context);
      return false;
    } catch (e) {
      return false;
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
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double screenHeight = constraints.maxHeight;
                  double scale = (screenHeight / 700).clamp(1.0, 1.5);
                  double smallSpacing = (screenHeight * 0.015 * scale).clamp(6, 28);
                  double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);

                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Título principal
                        Text(
                          'Digite o código e o código temporário',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: largeSpacing),
                        Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/images/logo_vocatio_pequena_transparente.png',
                          width: 100,
                          height: 100,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                                      
                        SizedBox(height: largeSpacing),
                        TextFieldDesign(controller: _codeController, hintText: "Digite o código", context: context),
                        SizedBox(height: smallSpacing),
                        TextFieldDesign(controller: _tempCodeController, hintText: "Digite o código temporário", context: context),
                        SizedBox(height: largeSpacing),
                                      
                        primaryButtonDesign(
                          context: context,
                          label: 'Concluir chamada',
                          width: 255,
                          height: 55.0,
                          onTap: () async {
                            await _handleCompleteAttendance();
                          },
                        ),
                      ],
                                      ),
                    ),
                  );
                } 
              ),
            ),
          );
        }
      }
      