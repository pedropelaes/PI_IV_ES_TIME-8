import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocattio/models/aluno_simple_info.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';

class AlunosTurmaScreen extends StatefulWidget{
  final String nomeTurma;
  final String turmaId;
  const AlunosTurmaScreen({
      super.key,
      required this.nomeTurma,
      required this.turmaId,
    });

  @override
  State<AlunosTurmaScreen> createState() => _AlunosTurmaScreenState();
}

class _AlunosTurmaScreenState extends State<AlunosTurmaScreen> {
  bool _carregando = false;
  String? _erro;
  List<AlunoSimpleInfo> _alunos = [];
  final SocketService _socketService = getIt<SocketService>();

  Future<void> _getAlunos() async{
    setState(() {
      _carregando = true;
      _erro = null;
      _alunos = [];
    });

    final jsonGetAlunos = {
      "operacao" : "GetAlunosSimples",
      "turmaId" : widget.turmaId
    };

    try{
      _socketService.send(jsonGetAlunos);

      final responseData = await _socketService.messages
      .firstWhere((data) {
        try{
          final message = jsonDecode(data is String ? data : utf8.decode(data));
          return message['operacao'] == 'ResultadoGetAlunosSimples';
        }catch(e){
          return false;
        }
      }).timeout(const Duration(seconds: 10));

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));

      if(mounted){
        setState(() {
          _carregando = false;
          if(responseJson['resultado'] == true && responseJson['alunos'] != null){
            final List<dynamic> alunosData = responseJson['alunos'];

            _alunos = alunosData
              .map((data) => AlunoSimpleInfo.fromJson(data as Map<String, dynamic>))
              .toList();

            if(_alunos.isEmpty){
              _erro = 'Nenhum aluno encontrado para essa turma';
            }
          }else{
            _alunos = [];
            _erro = 'Nenhum aluno encntrado para essa turma';
          }
        });
      }
    } on TimeoutException{
      if(mounted){
        setState(() {
          _carregando = false;
          _erro = 'Tempo de resposta esgotado';
        });
      }
    } catch(e){
      if(mounted){
        setState(() {
          _carregando = false;
          _erro = "Erro ao buscar alunos: $e";
        });
      }
    }
  }

  @override
  void initState(){
    super.initState();
    _getAlunos();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    
    return Scaffold(
      appBar: AppHeader(
        title: widget.nomeTurma,
        hasGoBack: true,
        onGoBack: (){
          Navigator.pop(context);
        },
        onMenuPressed: (){

        },
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isLargeScreen = constraints.maxWidth > 700;
              double screenHeight = constraints.maxHeight;
              double scale = (screenHeight / 700).clamp(1.0, 1.5);
              double smallSpacing = (screenHeight * 0.015 * scale).clamp(6, 28);
              double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);

              Widget _listaAlunos = 
              primaryFixedGradientContainer(
                theme: theme, 
                child: _carregando 
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primaryFixed,
                    ),
                  ),
                )
                : _erro != null
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _erro!,
                          style: textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : _alunos.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: theme.colorScheme.primaryFixed,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum aluno registrado nessa turma',
                          style: textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primaryFixed,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                :
                ListView.builder(
                  itemCount: _alunos.length,
                  itemBuilder: (context, index) {
                    final aluno = _alunos[index];

                    return ListTile(
                      leading: Icon(
                        Icons.account_circle_outlined,
                        color: theme.colorScheme.primaryFixed,
                      ),
                      title: Text(
                        aluno.nome,
                        style: textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primaryFixed
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () async{
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: aluno.email,
                          );
                          if (await canLaunchUrl(emailLaunchUri)) {
                            await launchUrl(emailLaunchUri);
                          }
                        }, 
                        icon: Icon(
                          Icons.mail,
                          color: theme.colorScheme.primaryFixed,
                        )
                      ),
                    );
                  },
                )
              );
              

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Alunos',
                    style: textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onSurface
                    ),
                  ),
                  SizedBox(height: smallSpacing,),
                  Expanded(
                    child: isLargeScreen ? Center(
                      child: SizedBox(
                        width: 1000,
                        child: _listaAlunos,
                      ),
                    )
                    : _listaAlunos,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}