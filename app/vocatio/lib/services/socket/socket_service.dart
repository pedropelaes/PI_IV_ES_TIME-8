import 'dart:async';
import 'dart:convert';

import 'socket_client_mobile.dart' 
  if (dart.library.html) 'socket_client_web.dart';

import 'socket_client.dart';

class SocketService {
  static const String host = '10.147.19.224';
  static const int port = 3000;

  final SocketClient _client = getSocketClient();
  final _controller = StreamController<dynamic>.broadcast();

  bool get isConnected => _client.isConnected;

  Stream<dynamic> get messages => _controller.stream;

  SocketService() {
    _client.stream.listen((data) {
      print('Servidor disse: $data');
      _controller.add(data);
    }, onError: (error) {
      print('Erro na conexão: $error');
      _controller.add(error);
    }, onDone: () {
      print('Conexão encerrada pelo servidor');
      _controller.close();
    });
  }

  Future<void> connect() async {
    if (isConnected) return;
    try {
      await _client.connect(host, port);
      print('Conectado com sucesso em $host:$port');
    } catch (e) {
      print('Falha ao conectar: $e');
    }
  }

  void send(Map<String, dynamic> data) {
    if (!isConnected) {
      print('Socket não está conectado.');
      return;
    }
    final message = jsonEncode(data);
    _client.send(message);
    print('Enviado: $message');
  }

  void disconnect() {
    _client.disconnect();
    print('Desconectado.');
  }
}