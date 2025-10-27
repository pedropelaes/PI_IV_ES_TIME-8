import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/services/auth_service.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';

class EntrarEmTurmaScreen extends StatefulWidget {
  final String objectId;
  const EntrarEmTurmaScreen({super.key, required this.objectId});

  @override
  State<EntrarEmTurmaScreen> createState() => _EntrarEmTurmaScreenState();
}

class _EntrarEmTurmaScreenState extends State<EntrarEmTurmaScreen> {

    final TextEditingController codeController = TextEditingController();
    final SocketService _socketService = getIt<SocketService>();
    final AuthService _authService = AuthService();
    late Future<User?> _user;

  @override
  void dispose(){
    codeController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Método para mostrar mensagens de sucesso
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<bool?> _entrarEmTurma() async {
    Map<String, dynamic> jsonEntrarEmTurma = {
      "operacao": "EntrarEmTurma",
      "objectId": widget.objectId,
      "codigoTurma": codeController.text
    };

    try {
      _socketService.send(jsonEntrarEmTurma);

      final responseData = await _socketService.messages.firstWhere(
        (data) {
          try {
            final message = jsonDecode(data is String ? data : utf8.decode(data));
            return message['operacao'] == 'ResultadoEntrarEmTurma';
          } catch (e) {
            return false;
          }
        },
      ).timeout(const Duration(seconds: 10)); 

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));
      
      final resultado = responseJson['resultado'];

      print("Resposta de entrada em turma: $resultado");

      if (resultado == 'true' || resultado == true) { 
        return true;
      } else {
        return false;
      }

    } on TimeoutException {
      print("Erro: Tempo de resposta para entrar em turma.");
      return null;
    } catch (e) {
      print("Erro ao processar resposta da entrada em turma: $e");
      return null; 
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Entrar Em Turma',
        hasGoBack: true,
        onGoBack: () => Navigator.pop(context),
        onMenuPressed: () {},
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isLargeScreen = constraints.maxWidth > 700;
              double screenHeight = constraints.maxHeight;
              double scale = (screenHeight / 700).clamp(1.0, 1.5);
              double smallSpacing = (screenHeight * 0.015 * scale).clamp(6, 28);
              double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      !isLargeScreen ?
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/images/logo_vocatio_pequena_transparente.png',
                          width: 100 ,
                          height: 100 ,
                          color: theme.colorScheme.onPrimary
                        ),
                      )
                      : ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 200, maxWidth: 400),
                          child: Image.asset('assets/images/logo_vocatio_transparente.png', fit: BoxFit.contain,)
                        ),
                      SizedBox(height: largeSpacing),
                
                      TextFieldDesign(controller: codeController, hintText: 'Digite o código da turma', context: context),
                      SizedBox(height: smallSpacing),
                
                      primaryButtonDesign(
                        context: context,
                        label: 'Entrar em Turma',
                        width: 255,
                        height: 55.0,
                        onTap: () async {
                          final resultado = await _entrarEmTurma();
                          if(resultado == true){
                            _showSuccessSnackBar("Entrada Realizada");
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                          else {
                            _showErrorSnackBar("Erro ao entrar na turma");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
