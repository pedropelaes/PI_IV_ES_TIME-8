import 'dart:async';
import 'dart:convert';

import 'package:vocattio/extensions/string_extensions.dart';
import 'package:vocattio/models/turma.dart';
import 'package:vocattio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/custom_fab.dart';
import 'package:vocattio/widgets/turma_card.dart';
import 'package:vocattio/screens/detalhes_turma.dart';
import 'package:vocattio/utils/responsive_helper.dart';

class HomeScreen extends StatefulWidget {
  final String uid;
  const HomeScreen({super.key, required this.uid});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SocketService _socketService = getIt<SocketService>();
  final AuthService _authService = AuthService();
  late Future<User?> _user;
  Future<List<Turma>?>? _turmas;

  Future<List<Turma>?> _getTurmas(final List<String>? turmasIds) async{
    if(turmasIds == null || turmasIds.isEmpty){
      print("Ta caindo aqui");
      return [];
    }

    Map<String, dynamic> jsonGetTurmas = {
      "operacao" : "GetTurmas",
      "turmasId" : turmasIds
    };

    try{
      final futureResponse = _socketService.messages.firstWhere((data) {
        try{
          final message = jsonDecode(data is String ? data : utf8.decode(data));
          return message['operacao'] == 'ResultadoGetTurmas';
        }catch(e){
          return false;
        }
      }).timeout(const Duration(seconds: 10));
      _socketService.send(jsonGetTurmas);

      final responseData = await futureResponse;
      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));

      final List<dynamic>? turmasJsonList = responseJson['turmas'];

      if (turmasJsonList == null) {
        print("Erro: Resposta do servidor não continha o campo 'turmas'.");
        return []; 
      }
      
      final List<Turma> resultado = turmasJsonList
          .map((turmaJson) => Turma.fromJson(turmaJson as Map<String, dynamic>))
          .toList();

      print("Resposta GetTurmas: $resultado");
      return resultado;
    }on TimeoutException{
      print("Erro: tempo de resposta esgotado para a busca das turmas");
      return null;
    }
    catch(e){
      print("Erro ao processar resposta do servidor: $e");
      return null;
    }
  }
  

  // Dados das turmas baseados na imagem
  //final List<Map<String, dynamic>> turmas = [];

  @override
  void initState(){
    super.initState();
    _user = _authService.getUser(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Turmas',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getMaxWidth(context),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
              child: FutureBuilder<User?>(
                future: _user,
                builder: (context, asyncSnapshot) {

                  if(asyncSnapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(color: theme.colorScheme.onSurface),);
                  }

                  if (asyncSnapshot.hasError || !asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Erro ao carregar dados do usuário.', style: textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.error
                        ),),
                        primaryButtonDesign(context: context, label: 'Retry', onTap: (){
                          setState(() {
                            _user = _authService.getUser(widget.uid);
                          });
                       
                        }, width: 255, height: 55)
                      ],
                    ),
                  );
                }

                  final user = asyncSnapshot.data;

                  _turmas ??= _getTurmas(user!.turmas);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saudação
                      Text(
                        'Olá, ${user?.tipo.capitalize()} ${user?.getNome()}',
                        style: textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Grid de turmas
                      Expanded(
                        child: FutureBuilder(
                          future: _turmas,
                          builder: (context, turmasSnapshot) {
                            if (turmasSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(color: theme.colorScheme.onSurface));
                            }

                            if (turmasSnapshot.hasError || !turmasSnapshot.hasData || turmasSnapshot.data == null) {
                              return Center(child: Text('Erro ao carregar as turmas.'));
                            }
                            
                            final turmas = turmasSnapshot.data!;
                            print("Turmas: $turmas");

                            if(turmas.isEmpty){
                              return Center(
                                child: Text(
                                  user!.tipo == 'professor' ? 'Você ainda não tem nenhuma turma' : 'Você ainda não está em nenhuma turma',
                                  textAlign: TextAlign.center,
                                  style: textTheme.displaySmall?.copyWith(
                                    color: theme.colorScheme.error
                                  ),
                                ),
                              );
                            }
                            
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: ResponsiveHelper.isDesktop(context) ? 1.0 : 0.85,
                              ),
                              itemCount: turmas.length,
                              itemBuilder: (context, index) {
                                final turma = turmas[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalhesTurmaScreen(
                                          tipoUsuario: user!.tipo,
                                          nomeTurma: turma.nome,
                                          descricao: turma.descricao,
                                          numeroAlunos: turma.alunos.length,
                                          codigoTurma: turma.codigo, // código humano da turma
                                          turmaId: turma.objectId,   // ObjectId para backend
                                        ),
                                      ),
                                    );
                                  },
                                  child: TurmaCard(
                                    nomeTurma: turma.nome,
                                    descricao: turma.descricao,
                                    numeroAlunos: turma.alunos.length,
                                  ),
                                );
                              },
                            );
                          }
                        )
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FutureBuilder<User?>(
        future: _user,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink(); // Esconde o FAB enquanto carrega
          }

          if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
            return const SizedBox.shrink(); // Esconde se der erro ou user for null
          }

          final user = asyncSnapshot.data!;
          print(user.objectId);
          return CustomFAB(tipo: user.tipo, objectId: user.objectId ?? "");
  },
),

    );
  }
}
