import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'socket_client.dart';

class SocketClientMobile implements SocketClient {
  Socket? _socket;
  final _controller = StreamController<dynamic>.broadcast();

  List<int> _buffer = [];

  @override
  Stream<dynamic> get stream => _controller.stream;

  @override
  bool get isConnected => _socket != null;

  @override
  Future<void> connect(String host, int port) async {
    try {
      _socket = await Socket.connect(host, port);
      _socket!.listen(
        _onData,
        onDone:(){ 
          _controller.addError(Exception('Socket fechado pelo servidor'));
          disconnect();
        },
        onError: (error) => _controller.addError(error),
      );
    } catch (e) {
      _controller.addError(e);
      rethrow;
    }
  }
  void _onData(Uint8List data) {

    _buffer.addAll(data);

    while (true) {
      final index = _buffer.indexOf(10); 
      
      if (index == -1) {
        break; 
      }

      final messageBytes = _buffer.sublist(0, index);
      
      try {
        final messageString = utf8.decode(messageBytes);
        if (messageString.trim().isNotEmpty) {
          _controller.add(messageString);
        }
      } catch (e) {
        print("Erro ao decodificar mensagem: $e");
      }

      
      _buffer = _buffer.sublist(index + 1);
    }
  }

  @override
  void send(String message) {
    _socket?.write('$message\n');
  }

  @override
  void disconnect() {
    _socket?.destroy();
    _socket = null;
    _buffer.clear();
  }
}

SocketClient getSocketClient() => SocketClientMobile();