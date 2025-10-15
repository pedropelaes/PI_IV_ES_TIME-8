import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> connect() async {
  if(kIsWeb){
    // WebSocket para conexão web
  }else{
    final socket = await Socket.connect('localhost', 3000);
    print('Conectado ao servidor');

    // Envia o comando R
    final message = jsonEncode({"tipo": "TesteMongo",
      "nome": "neguinho",
      "email": "penery02@gmail.com",
      "idade": 19});
    socket.write('$message\n');

    // Recebe a resposta
    socket.listen((data) {
      print('Servidor respondeu: ${utf8.decode(data)}');
    });
  }
}
