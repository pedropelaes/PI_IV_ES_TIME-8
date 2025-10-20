import 'dart:async';
import 'dart:convert';

import 'package:vocattio/extensions/string_extensions.dart';
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
  

  // Dados das turmas baseados na imagem
  final List<Map<String, dynamic>> turmas = [
    {'nome': 'Turma 1', 'descricao': 'Descrição *', 'alunos': 32},
    {'nome': 'Turma 2', 'descricao': 'Descrição *', 'alunos': 51},
    {'nome': 'Turma 3', 'descricao': 'Descrição *', 'alunos': 17},
    {'nome': 'Turma 4', 'descricao': 'Descrição *', 'alunos': 30},
    {'nome': 'Turma 5', 'descricao': 'Descrição *', 'alunos': 42},
    {'nome': 'Turma 6', 'descricao': 'Descrição *', 'alunos': 0},
  ];

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
                        child: GridView.builder(
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
                                      nomeTurma: turma['nome'],
                                      descricao: turma['descricao'],
                                      numeroAlunos: turma['alunos'],
                                    ),
                                  ),
                                );
                              },
                              child: TurmaCard(
                                nomeTurma: turma['nome'],
                                descricao: turma['descricao'],
                                numeroAlunos: turma['alunos'],
                              ),
                            );
                          },
                        ),
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
