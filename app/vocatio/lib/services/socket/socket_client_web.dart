import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'socket_client.dart';

class SocketClientWeb implements SocketClient {
  web.WebSocket? _webSocket;
  final _controller = StreamController<dynamic>.broadcast();

  @override
  Stream<dynamic> get stream => _controller.stream;

  @override
  bool get isConnected => _webSocket?.readyState == web.WebSocket.OPEN;

  @override
  Future<void> connect(String host, int port) async {
    _webSocket = web.WebSocket('ws://$host:$port');
    final completer = Completer<void>();

    _webSocket?.addEventListener('open', (web.Event event) {
      if (!completer.isCompleted) {
        print("Conexao estabelecida"); 
        completer.complete();
      }
    }.toJS);

    _webSocket?.addEventListener('message', (web.MessageEvent event) {
      _controller.add(event.data);
    }.toJS);

    _webSocket?.addEventListener('close', (web.CloseEvent event) {
      _webSocket = null;
      _controller.close();
    }.toJS);

    _webSocket?.addEventListener('error', (web.Event event) {
      final error = Exception('Erro no WebSocket');
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
      if (!_controller.isClosed) {
        _controller.addError(error);
      }
    }.toJS);

    return completer.future;
  }

  @override
  void send(String message) {
    _webSocket?.send(message.toJS);
  }

  @override
  void disconnect() {
    _webSocket?.close();
  }
}

SocketClient getSocketClient() => SocketClientWeb();