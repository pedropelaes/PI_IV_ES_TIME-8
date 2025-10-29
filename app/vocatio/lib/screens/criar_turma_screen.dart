import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';

class CriarTurmaScreen extends StatefulWidget {
  final String objectId;
  const CriarTurmaScreen({super.key, required this.objectId});

  @override
  State<CriarTurmaScreen> createState() => _CriarTurmaScreenState();
}

class _CriarTurmaScreenState extends State<CriarTurmaScreen> {

    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final SocketService _socketService = getIt<SocketService>();

  @override
  void dispose(){
    nameController.dispose();
    descriptionController.dispose();
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

  Future<bool?> _criarTurma() async {
    Map<String, dynamic> jsonCriarTurma = {
      "operacao": "CriarTurma",
      "nome": nameController.text,
      "descricao": descriptionController.text,
      "objectId": widget.objectId
    };

    try {
      _socketService.send(jsonCriarTurma);

      final responseData = await _socketService.messages.firstWhere(
        (data) {
          try {
            final message = jsonDecode(data is String ? data : utf8.decode(data));
            return message['operacao'] == 'ResultadoCriarTurma';
          } catch (e) {
            return false;
          }
        },
      ).timeout(const Duration(seconds: 10)); 

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));
      
      final resultado = responseJson['resultado'];

      print("Resposta de criação de turma: $resultado");

      if (resultado == 'true' || resultado == true) { 
        return true;
      } else {
        return false;
      }

    } on TimeoutException {
      print("Erro: Tempo de resposta para a criação de turma.");
      return null;
    } catch (e) {
      print("Erro ao processar resposta da criação de turma: $e");
      return null; 
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Nova Turma',
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
                
                      TextFieldDesign(controller: nameController, hintText: 'Digite o nome da turma', context: context),
                      SizedBox(height: smallSpacing),
                
                      TextFieldDesign(controller: descriptionController, hintText: 'Descrição (opcional)', context: context),
                      SizedBox(height: largeSpacing),
                
                      primaryButtonDesign(
                        context: context,
                        label: 'Criar Turma',
                        width: 255,
                        height: 55.0,
                        onTap: () async {
                          final resultado = await _criarTurma();
                          if(resultado == true){
                            _showSuccessSnackBar("Turma Criada!");
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                          else {
                            _showErrorSnackBar("Erro ao criar turma");
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
