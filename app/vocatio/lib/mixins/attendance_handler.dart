import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vocattio/services/location/location_service.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/widgets/snackbars.dart';

mixin AttendanceHandler<T extends StatefulWidget> on State<T> {
  final locationService = LocationService();
  Position? currentLocation;
  bool isGettingLocation = false;
  User? currentUser;
  
  void initUserSession() {
    if (getIt.isRegistered<User>()) {
      currentUser = getIt<User>();
    } else {
      if (mounted) showErrorSnackBar("Erro de sessão, reiniciando app.", context);
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) Phoenix.rebirth(context);
      });
    }
  }

  Future<Position?> getCurrentLocation() async {
    if (isGettingLocation) return null;

    print('=== INICIANDO OBTENÇÃO DE LOCALIZAÇÃO ===');
    setState(() {
      isGettingLocation = true;
    });

    try {
      print('PASSO 1: Verificando permissões...');
      bool hasPermission = await locationService.checkLocationPermission();
      if (!hasPermission) {
        print('Permissões não concedidas, abortando...');
        if(mounted) showErrorSnackBar('Você precisa dar permissão de localização.', context);
        setState(() => isGettingLocation = false);
        return null;
      }

      print('PASSO 2: Verificando serviços de localização...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Serviços de localização desabilitados');
        if (mounted) {
          locationService.showPermissionDialog(
            context,
            'Serviços de Localização Desabilitados',
            'Os serviços de localização estão desabilitados. Por favor, habilite-os.',
            'Ir para Configurações',
            () async {
              await Geolocator.openLocationSettings();
            },
          );
        }
        setState(() => isGettingLocation = false);
        return null;
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

      if (position.accuracy > 100) {
        if (mounted) showErrorSnackBar('Não foi possivel obter sua localização com precisão.', context);
        throw Exception('Precisão baixa');
      }
      
      print('SUCESSO: Localização obtida - Lat: ${position.latitude}, Lng: ${position.longitude}');
      setState(() {
        currentLocation = position;
        isGettingLocation = false;
      });

      if (mounted) showSuccessSnackBar('Localização obtida com sucesso!', context);
      return position;

    } catch (e) {
      print('ERRO ao obter localização: $e');
      setState(() {
        isGettingLocation = false;
      });

      String errorMessage = 'Erro ao obter localização.';
      if (e.toString().contains('timeout')) {
        errorMessage = ' Timeout: GPS pode estar desabilitado ou em ambiente fechado.';
      } else if (e.toString().contains('permission')) {
        errorMessage = ' Permissão de localização necessária.';
      }

      if (mounted) showErrorSnackBar(errorMessage, context);
      return null;
    }
  }

  Future<bool> registrarPresenca({
    required String aulaId,
    required String codigoTemporario,
  }) async {
    if (currentUser == null || currentUser!.objectId == null) {
      if (mounted) showErrorSnackBar('Erro: Usuário não identificado.', context);
      return false;
    }
    
    // A localização já deve ter sido obtida por 'getCurrentLocation'
    if (currentLocation == null) {
      if (mounted) showErrorSnackBar('Erro: Localização não obtida.', context);
      return false;
    }

    final socket = getIt<SocketService>();
    final jsonRegistrar = {
      "operacao": "RegistrarPresenca",
      "codigoChamada": aulaId,
      "codigoTemporario": codigoTemporario, 
      "alunoId": currentUser!.objectId!,
      "latitude": currentLocation!.latitude,
      "longitude": currentLocation!.longitude,
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
        if (mounted) showSuccessSnackBar("Presença registrada com sucesso!", context);
        return true;
      } else {
        if (mounted) {
          final msg = responseJson['mensagem'] ?? 'Erro ao registrar presença';
          showErrorSnackBar("Erro: ${msg}", context);
        }
        return false;
      }
    } catch (e) {
      if (mounted) showErrorSnackBar("Erro de comunicação com o servidor: $e", context);
      return false;
    }
  }
}