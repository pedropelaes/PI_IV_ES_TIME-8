import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> checkLocationPermission() async {
    if (kIsWeb) {
      // Lógica específica para a Web
      LocationPermission geoPermission = await Geolocator.checkPermission();
      
      if (geoPermission == LocationPermission.denied) {
        // No navegador, requestPermission abre o popup de permissão
        geoPermission = await Geolocator.requestPermission();
      }
      
      if (geoPermission == LocationPermission.whileInUse || geoPermission == LocationPermission.always) {
        print("Permissão de localização concedida na Web: $geoPermission");
        return true;
      } else {
        print("Permissão de localização negada na Web: $geoPermission");
        return false;
      }

    } else {
      // Passo 1: Verifica permissão atual
      LocationPermission geoPermission = await Geolocator.checkPermission();

      // Passo 2: Solicita "When in Use" se ainda não tiver
      if (geoPermission == LocationPermission.denied ||
          geoPermission == LocationPermission.deniedForever) {
        geoPermission = await Geolocator.requestPermission();
      }

      // Passo 3: Se for iOS e já tiver "When in Use", tenta pedir "Always"
      if ( Platform.isMacOS|| Platform.isIOS && geoPermission == LocationPermission.whileInUse) {
        geoPermission = await Geolocator.requestPermission();
      }

      // Passo 4: Confere resultado final
      if (geoPermission == LocationPermission.always ||
          geoPermission == LocationPermission.whileInUse) {
        print("Permissão de localização concedida no Mobile: $geoPermission");
        return true;
      } else {
        print("Permissão de localização negada no Mobile: $geoPermission");
        return false;
      }
    }
  }


  // Mostrar diálogo de permissão
  void showPermissionDialog(BuildContext context,String title, String message, String buttonText, VoidCallback onPressed) {
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

  static Future<Position?> obterPosicaoInicialRapida() async {
    try {
      // 1. Verifica se tem permissão (não pede, só verifica)
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        print('Permissão negada. Não é possível obter posição inicial.');
        return null; // Retorna nulo se a permissão já foi negada
      }
      
      // 2. Tenta obter a posição com baixa precisão (mais rápido)
      // e um time limit curto.
      Position posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // Pedimos 'low' pois 'high' pode falhar em conexões cabeadas
          // que não reportam 'accuracy' e não queremos um erro,
          // queremos apenas a localização de IP.
          accuracy: LocationAccuracy.low, 
        ),
        timeLimit: const Duration(seconds: 5), // 5 segundos é o bastante
      );
      
      return posicao;

    } catch (e) {
      // Se falhar (serviços desligados, timeout, etc),
      // retorna nulo silenciosamente.
      print('Erro ao obter posição inicial rápida: $e');
      return null;
    }
  }

}

class ValidadorLocalizacao {

  /// Valida se o usuário está dentro do [raioMetros] em relação à
  /// localização do professor ([professorLat], [professorLon]).
  /// O raio padrão é 100 metros.
  static Future<bool> validarLocalizacao({
    required double professorLat,
    required double professorLon,
    double raioMetros = 100,
  }) async {
    try {
      // Garante que a permissão foi concedida
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
      }
      if (perm != LocationPermission.always && perm != LocationPermission.whileInUse) {
        print('Permissão de localização não concedida: $perm');
        return false;
      }

      // Obter posição atual do usuário
      Position posicaoAtual = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      print('Posição atual: Latitude ${posicaoAtual.latitude}, Longitude ${posicaoAtual.longitude}');

      final double distancia = Geolocator.distanceBetween(
        professorLat,
        professorLon,
        posicaoAtual.latitude,
        posicaoAtual.longitude,
      );

      print('Distância até professor: ${distancia.toStringAsFixed(2)}m (raio permitido: ${raioMetros}m)');

      return distancia <= raioMetros;
    } catch (e) {
      print('Erro ao validar localização: $e');
      return false;
    }
  }

  /// Obtém a posição atual do usuário
  static Future<Position?> obterPosicaoAtual() async {
    try {
      Position posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return posicao;
    } catch (e) {
      print('Erro ao obter posição atual: $e');
      return null;
    }
  }

  /// Calcula a distância do usuário até a localização do professor
  static Future<double?> calcularDistanciaAteProfessor({
    required double professorLat,
    required double professorLon,
  }) async {
    try {
      final posicaoAtual = await obterPosicaoAtual();
      if (posicaoAtual == null) return null;

      return Geolocator.distanceBetween(
        professorLat,
        professorLon,
        posicaoAtual.latitude,
        posicaoAtual.longitude,
      );
    } catch (e) {
      print('Erro ao calcular distância até o professor: $e');
      return null;
    }
  }
}