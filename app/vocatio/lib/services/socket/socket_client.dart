abstract class SocketClient {
  Stream<dynamic> get stream;
  bool get isConnected;
  
  Future<void> connect(String host, int port);
  void send(String message);
  void disconnect();
}