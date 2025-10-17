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
    /*final message = jsonEncode({"operacao": "Cadastro",
      "nome": "pai do mewtwo",
      "email": "paidomewtwo@gmail.com",
      "tipo": "aluno",
      "codigo": "31251241",
      });*/
    //final message = jsonEncode({"operacao": "PedidoParaSair"});

    final message = jsonEncode({
      "operacao": "Login",
      "uid": "1",
    });
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
