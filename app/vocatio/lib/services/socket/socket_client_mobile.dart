import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'socket_client.dart';

class SocketClientMobile implements SocketClient {
  Socket? _socket;
  final _controller = StreamController<dynamic>.broadcast();

  @override
  Stream<dynamic> get stream => _controller.stream;

  @override
  bool get isConnected => _socket != null;

  @override
  Future<void> connect(String host, int port) async {
    try {
      _socket = await Socket.connect(host, port);
      _socket!.listen(
        (data) => _controller.add(utf8.decode(data)),
        onDone: disconnect,
        onError: (error) => _controller.addError(error),
      );
    } catch (e) {
      _controller.addError(e);
      rethrow;
    }
  }

  @override
  void send(String message) {
    _socket?.write('$message\n');
  }

  @override
  void disconnect() {
    _socket?.close();
    _socket = null;
    _controller.close();
  }
}

SocketClient getSocketClient() => SocketClientMobile();