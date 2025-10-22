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