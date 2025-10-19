import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:vocattio/models/user.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';


class AuthService {
  final String apiKey = dotenv.env['FIREBASE_API_WEB_KEY'] ?? '';
  final SocketService _socketService = getIt<SocketService>();

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> sendEmailVerification(String idToken) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestType': 'VERIFY_EMAIL',
        'idToken': idToken,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async{
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$apiKey'
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestType': 'PASSWORD_RESET',
        'email': email,
      }) 
    );
    return jsonDecode(response.body);
  }

  Future<User?> getUser(String uid) async {
    Map<String, dynamic> jsonLogin = {
      "operacao": "Login",
      "uid" : uid,
    };

    try{
      final futureResponse = _socketService.messages.firstWhere((data) {
      try {
          final message = jsonDecode(data is String ? data : utf8.decode(data));
          return message['operacao'] == 'ResultadoLogin';
        } catch (e) {
          return false;
        }
      }).timeout(const Duration(seconds: 10));
      _socketService.send(jsonLogin);

      final responseData = await futureResponse;

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));

      final Map<String, dynamic> userJson = responseJson['user'];
      final User resultado = User.fromJson(userJson);
      print("Resposta de login recebida: $resultado");

      return resultado;

    }on TimeoutException{
      print("Erro: Tempo de resposta para o login esgotado.");
      return null;
    }
    catch(e){
      print("Erro ao processar resposta do cadastro: $e");
      return null; 
    }
  }

}


