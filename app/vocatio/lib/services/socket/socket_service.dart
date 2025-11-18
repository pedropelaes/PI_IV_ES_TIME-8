import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'socket_client_mobile.dart' 
  if (dart.library.html) 'socket_client_web.dart';

import 'socket_client.dart';

enum ConnectionStatus {connected, connecting, disconnected, reconnecting}

class SocketService {
  static const String host = 'localhost'; 
  static int  get port => kIsWeb ? 3001 : 3000;

  final SocketClient _client = getSocketClient();
  final _controller = StreamController<dynamic>.broadcast();

  bool _connectionLostNotified = false;
  bool get isConnected => _client.isConnected;

  Stream<dynamic> get messages => _controller.stream;

  final ValueNotifier<ConnectionStatus> connectionStatus = ValueNotifier(ConnectionStatus.disconnected);

  VoidCallback? onConnectionLost;
  VoidCallback? onConnected;

  SocketService() {
    _client.stream.listen((data) {
      print('Servidor disse: $data');
      _controller.add(data);
    }, onError: (error) {
      print('Erro na conexão: $error');
      _controller.addError(error);
      if(!_connectionLostNotified){
        _connectionLostNotified = true;
        connectionStatus.value = ConnectionStatus.disconnected;
        onConnectionLost?.call();
      }
    }, onDone: () {
      print('Conexão encerrada pelo servidor');
      if(!_connectionLostNotified){
        _connectionLostNotified = true;
        connectionStatus.value = ConnectionStatus.disconnected;
        onConnectionLost?.call();
      }
    });
  }

  Future<void> connect() async {
    if (isConnected) return;
    connectionStatus.value = ConnectionStatus.connecting;
    try {
      await _client.connect(host, port);
      _connectionLostNotified = false;
      connectionStatus.value = ConnectionStatus.connected;
      print('Conectado com sucesso em $host:$port');

      try{
        onConnected?.call();
      }catch(e){
        print("Erro ao notificar onConnected: $e");
      }
    } catch (e) {
      print('Falha ao conectar: $e');
      connectionStatus.value = ConnectionStatus.disconnected;
      rethrow;
    }
  }

  Future<void> tryReconnectWithBackoff({int maxAttempts = 5}) async {
    connectionStatus.value = ConnectionStatus.reconnecting;
    int attempts = 0;
    while (attempts < maxAttempts && !isConnected) {
      attempts++;
      try {
        await connect();
        return;
      } catch (_) {
        print('Falha ao reconectar (tentativa :$attempts)');
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
    if (!isConnected) connectionStatus.value = ConnectionStatus.disconnected;
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

  Future<void> pedidoParaSair() async {
    if(isConnected){
      print("Enviando pedido para sair");

      send({'operacao' : 'PedidoParaSair'});
      await Future.delayed(const Duration(milliseconds: 100));

      disconnect();
    }
  }
}