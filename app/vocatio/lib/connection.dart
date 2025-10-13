import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> conect() async {
  if(kIsWeb){
    // WebSocket para conexão web
  }else{
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
}
