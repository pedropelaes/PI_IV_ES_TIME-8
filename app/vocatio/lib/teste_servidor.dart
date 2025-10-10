import 'dart:io';
import 'dart:convert';

Future<void> conectar() async {
  final socket = await Socket.connect('127.0.0.1', 3000);
  print('Conectado ao servidor');

  // Envia o comando R
  socket.write('R\n');

  // Recebe a resposta
  socket.listen((data) {
    print('Servidor respondeu: ${utf8.decode(data)}');
  });
}
