import 'dart:io';
import 'dart:convert';

Future<void> conectar() async {
  final socket = await Socket.connect('192.168.0.5', 3000);
  print('Conectado ao servidor');

  // Envia o comando R
  final message = jsonEncode({"tipo": "PedidoDeResultado"});
  socket.write('$message\n');

  // Recebe a resposta
  socket.listen((data) {
    print('Servidor respondeu: ${utf8.decode(data)}');
  });
}
