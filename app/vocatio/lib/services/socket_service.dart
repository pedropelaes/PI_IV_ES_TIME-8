import 'dart:convert';
import 'dart:io' show Socket; // só é usado quando não for web
import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:html' as html; // só é usado quando for web

class SocketService {
  static const String host = 'localhost';
  static const int port = 3000;

  Socket? _socket;
  html.WebSocket? _webSocket;
  bool _isConnected = false;

  Future<void> connect() async {
    if (_isConnected) return;

    if (kIsWeb) {
      try {
        _webSocket = html.WebSocket('ws://$host:$port');
        _webSocket!.onOpen.listen((_) {
          print('WebSocket conectado em ws://$host:$port');
          _isConnected = true;
        });
        _webSocket!.onMessage.listen((event) {
          print('Servidor (web): ${event.data}');
        });
        _webSocket!.onClose.listen((_) {
          print('Conexão WebSocket encerrada');
          _isConnected = false;
        });
        _webSocket!.onError.listen((_) {
          print('Erro no WebSocket');
          _isConnected = false;
        });
      } catch (e) {
        print('Erro ao conectar WebSocket: $e');
      }
    } else {
      try {
        _socket = await Socket.connect(host, port);
        _isConnected = true;
        print('Socket conectado em $host:$port');

        _socket!.listen(
          (data) {
            final message = utf8.decode(data);
            print('Servidor (mobile): $message');
          },
          onDone: () {
            print('Conexão encerrada pelo servidor');
            _isConnected = false;
          },
          onError: (error) {
            print('Erro na conexão: $error');
            _isConnected = false;
          },
        );
      } catch (e) {
        print('Erro ao conectar: $e');
      }
    }
  }

  void send(Map<String, dynamic> data) {
    final message = jsonEncode(data);

    if (kIsWeb) {
      if (_webSocket == null || _webSocket!.readyState != html.WebSocket.OPEN) {
        print('WebSocket não conectado');
        return;
      }
      _webSocket!.sendString(message);
      print('Enviado (web): $message');
    } else {
      if (_socket == null) {
        print('Socket não conectado');
        return;
      }
      _socket!.write('$message\n');
      print('Enviado (mobile): $message');
    }
  }

  void disconnect() {
    if (kIsWeb) {
      _webSocket?.close();
      _isConnected = false;
      print('Desconectado do WebSocket');
    } else {
      _socket?.close();
      _isConnected = false;
      print('Desconectado do Socket');
    }
  }
}
