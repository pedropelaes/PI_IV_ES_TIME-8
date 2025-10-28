import 'dart:io';

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

}

class ValidadorLocalizacao {
  // Coordenadas do Campus I com raio permitido
  static const Map<String, Map<String, double>> campi = {
    'Campus I': {
      'lat': -22.8197,
      'lon': -47.0586,
      'raio': 600, 
    },
  };

  
  static Future<bool> validarLocalizacao() async {
    try {
      // Obter posição atual do usuário
      Position posicaoAtual = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      print('Posição atual: Latitude ${posicaoAtual.latitude}, Longitude ${posicaoAtual.longitude}');


      for (var campus in campi.values) {
        double latCampus = campus['lat']!;
        double lonCampus = campus['lon']!;
        double raioPermitido = campus['raio']!;

       
        double distancia = Geolocator.distanceBetween(
          latCampus,
          lonCampus,
          posicaoAtual.latitude,
          posicaoAtual.longitude,
        );

        print('Distância do campus: ${distancia.toStringAsFixed(2)} metros (raio permitido: ${raioPermitido}m)');

      
        if (distancia <= raioPermitido) {
          print(' Usuário está dentro do campus');
          return true;
        }
      }

      print(' Usuário está fora do campus');
      return false;
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

  /// Calcula a distância até o campus mais próximo
  static Future<double?> calcularDistanciaAteCampus() async {
    try {
      Position? posicaoAtual = await obterPosicaoAtual();
      
      if (posicaoAtual == null) {
        return null;
      }

      double menorDistancia = double.infinity;

      for (var campus in campi.values) {
        double latCampus = campus['lat']!;
        double lonCampus = campus['lon']!;

        double distancia = Geolocator.distanceBetween(
          latCampus,
          lonCampus,
          posicaoAtual.latitude,
          posicaoAtual.longitude,
        );

        if (distancia < menorDistancia) {
          menorDistancia = distancia;
        }
      }

      return menorDistancia;
    } catch (e) {
      print('Erro ao calcular distância até o campus: $e');
      return null;
    }
  }
}