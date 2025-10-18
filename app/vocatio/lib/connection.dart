import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> connect(String? uid, String name, String email, String tipo, String codigo) async {
  if(kIsWeb){
    // WebSocket para conexão web
  }else{
    final socket = await Socket.connect('localhost', 3000);
    print('Conectado ao servidor');

    final message = jsonEncode({"operacao": "Cadastro",
      "uid": uid,
      "nome": name,
      "email": email,
      "tipo": tipo,
      "codigo": codigo,
      });
    //final message = jsonEncode({"operacao": "PedidoParaSair"});

   /* final message = jsonEncode({
      "operacao": "Login",
      "uid": "1",
    });*/
    socket.write('$message\n');

    // Recebe a resposta
    socket.listen((data) {
      if(data.contains('logout')){ 
        socket.close();
        print('Conexao fechada');
      }; 
      print('Servidor respondeu: ${utf8.decode(data)}');
    });

    
  }
}
