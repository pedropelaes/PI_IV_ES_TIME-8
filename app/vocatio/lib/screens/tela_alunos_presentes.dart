import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vocattio/models/presenca.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/dialog_exc.dart';
import 'package:vocattio/widgets/snackbars.dart';

class TelaAlunosPresentes extends StatefulWidget{
  final String idChamada;
  final String nomeTurma;
  final String data;
  final List<Presenca> alunosPresentes;
  final bool isEditavel;
  final bool isDeletavel;
  const TelaAlunosPresentes({super.key, required this.idChamada, required this.nomeTurma ,required this.data, required this.alunosPresentes, required this.isEditavel, required this.isDeletavel});

  @override
  State<TelaAlunosPresentes> createState() => _TelaAlunosPresentesState();
}

class _TelaAlunosPresentesState extends State<TelaAlunosPresentes> {
  final User currentUser = getIt<User>();
  final SocketService _socketService = getIt<SocketService>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Presenca> _alunosPresentes = [];
  List<Presenca> _editados = [];
  Map<String, bool> _presencasTemporarias = {};
  bool _carregando = false;
  bool _editando = false;
  String? _erro;
  bool _mudancasSalvas = false;


  @override
  void initState(){
    super.initState();
    _alunosPresentes.addAll(widget.alunosPresentes);
    for (final aluno in widget.alunosPresentes) {
      _presencasTemporarias[aluno.alunoId] = aluno.presente;
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        Navigator.pop(context, _mudancasSalvas);
      },
      child: Scaffold(
        key: _scaffoldKey, 
        appBar: AppHeader(
          title: widget.nomeTurma,
          hasGoBack: true,
          onMenuPressed: (){
            _scaffoldKey.currentState?.openDrawer();
          },
          onGoBack: (){
            Navigator.pop(context, _mudancasSalvas);
          },
        ),
        drawer: AppDrawer(
          user: currentUser,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints){
                final bool isLargeScreen = constraints.maxWidth > 700;
                double screenHeight = constraints.maxHeight;
                double scale = (screenHeight / 700).clamp(1.0, 1.5);
                double smallSpacing = (screenHeight * 0.015 * scale).clamp(6, 28);
                //double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);        

                Widget listaPresentes = 
                  primaryFixedGradientContainer(
                    theme: theme, 
                    child: _carregando ?
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                      : _alunosPresentes.isEmpty ?
                        Center(
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
                                  'Nenhum aluno teve presença registrada.',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primaryFixed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) :
                        ListView.builder(
                          itemCount: _alunosPresentes.length,
                          cacheExtent: 1,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final aluno = _alunosPresentes[index];
                            final bool presenteTemp = _presencasTemporarias[aluno.alunoId] ?? aluno.presente;
                            Widget trailingIcon; 
                            if (_editando) {
                              trailingIcon = Icon(
                                presenteTemp ? Icons.check_circle : Icons.cancel,
                                color: presenteTemp ? theme.colorScheme.primaryFixed : theme.colorScheme.error,
                                size: 28,
                              );
                            } else {
                              trailingIcon = Icon(
                                aluno.presente ? Icons.check_circle : Icons.cancel,
                                color: aluno.presente
                                    ? theme.colorScheme.primaryFixed
                                    : theme.colorScheme.error,
                                size: 28,
                              );
                            }
                    
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 4.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      Icons.account_circle,
                                      color: theme.colorScheme.primaryFixed,
                                    ),
                                    title: Text(
                                      _alunosPresentes[index].nome,
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.primaryFixed
                                      ),
                                    ),
                                    trailing: trailingIcon,
                                    onTap: (){
                                      if(_editando){
                                        if (_editando) {
                                          setState(() {
                                            final atual = _presencasTemporarias[aluno.alunoId] ?? aluno.presente;
                                            _presencasTemporarias[aluno.alunoId] = !atual;
                                          });
                                        }
                                      }
                                    },
                                  ),
                    
                                  if(index + 1 != _alunosPresentes.length)
                                  Divider(
                                    color: theme.colorScheme.primaryFixed,
                                    thickness: 2,
                                  )
                                ].animate(delay: (100 * index).ms).flipH(perspective: !isLargeScreen ? -0.5 : 0, begin: 0.3).fadeIn(),
                              ),
                            );
                          },
                        )
                  ).animate(
                    target: _editando ? 1.0 : 0.0, 
                    onComplete: (controller) {
                      if(_editando) controller.repeat();
                    },
                  ).boxShadow(
                    duration: 1.5.seconds,
                    curve: Curves.easeIn,
                    borderRadius: BorderRadius.circular(20),
                    begin: _editando ? BoxShadow(
                        color: theme.colorScheme.tertiary,
                        blurRadius: 15.0,
                        spreadRadius: 1.0,
                        blurStyle: BlurStyle.outer
                      ) : null
                  );
            
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.data,
                      style: textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: smallSpacing,),
                    Expanded(
                      child: isLargeScreen ? Center(
                        child: SizedBox(
                          width: 1000,
                          child: listaPresentes,
                        ),
                      )
                      : listaPresentes
                    ),
                    SizedBox(height: smallSpacing,),
                    if(!_editando)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        primaryButtonDesign(
                          context: context, 
                          enabled: widget.isEditavel,
                          label: 'Editar lista de presença', 
                          onTap: (){
                            setState(() {
                              _editando = true;
                            });
                          }, 
                          width: 250, 
                          height: 55
                        ),
                        if(widget.isDeletavel)
                        Padding(
                          padding: EdgeInsets.only(left: smallSpacing),
                          child: InkWell(
                            onTap: () async {
                              final bool confirmar = await showCustomDialog(
                                isCritical: true,
                                context, 
                                Icons.delete_forever_outlined,
                                'Confirmar exclusão', 
                                'Tem certeza que deseja excluir esta chamada? Esta ação não pode ser desfeita.', 
                                () { 
                                  Navigator.pop(context, true);
                                }, 
                                'Excluir'
                              ) ?? false;

                              if(confirmar){
                                final bool resultado = await _deletarChamada();
                                if(resultado && mounted){
                                  Navigator.pop(context, true);
                                }
                              }
                            },
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete,
                                color: theme.colorScheme.onError,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if(_editando)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        cancelButtonDesign(
                          context: context, 
                          label: 'Cancelar',
                          onTap: (){
                            setState(() {
                              _editando = false;
                              _editados.clear();
                              for (final aluno in _alunosPresentes) {
                                _presencasTemporarias[aluno.alunoId] = aluno.presente;
                              }
                            });
                          },
                          width: 150, 
                          height: 55
                        ),
                        SizedBox(width: smallSpacing,),
                        primaryButtonDesign(
                          context: context, 
                          label: 'Confirmar', 
                          enabled: widget.isEditavel,
                          onTap: ()async {
                              _editados.clear();
          
                              final List<Presenca> novaListaPrincipal = [];
          
                              for (final aluno in _alunosPresentes) {
                                // Pega o valor mais recente (editado ou não)
                                final bool novoValor = _presencasTemporarias[aluno.alunoId] ?? aluno.presente;
          
                                if (novoValor != aluno.presente) {
                                  final Presenca alunoEditado = aluno.copyWith(presente: novoValor);
                                  
                                  novaListaPrincipal.add(alunoEditado);
                                  
                                  _editados.add(alunoEditado);
                                } else {
                                  novaListaPrincipal.add(aluno); // aluno não mudou, mantém presença igual
                                }
                              }
          
                              final List<Presenca> backup = List.from(_alunosPresentes);
          
                              setState(() { // update otimista
                                _editando = false;
                                _alunosPresentes.clear();
                                _alunosPresentes.addAll(novaListaPrincipal);
                              });
          
                              if(_editados.isNotEmpty){
                                bool resultado = await _editarPresencas(_editados);
                                if(!resultado){ // restaura a lista em caso de erro
                                  setState(() {
                                    _alunosPresentes.clear();
                                    _alunosPresentes.addAll(backup);
                                    for(final aluno in _alunosPresentes){
                                      _presencasTemporarias[aluno.alunoId] = aluno.presente;
                                    }
                                  });
                                }
                              }
                            
                          }, 
                          width: 150,
                          height: 55)
                      ],
                    )
                  ],
                );
              },
            ),
            
          ),
        ),
      ),
    );
  }

  Future<bool> _editarPresencas(List<Presenca> editados) async{
    Map<String, dynamic> jsonEditarPresencas = {
      "operacao" : "EditarChamada",
      "codigoChamada" : widget.idChamada,
      "presentesEditados" : editados.map((aluno) => aluno.toJson()).toList()
    };

    try{
      _socketService.send(jsonEditarPresencas);

      final responseData = await _socketService.messages.firstWhere(
        (data) {
          try{
            final message = jsonDecode(data is String ? data : utf8.decode(data));
            return message['operacao'] == 'ResultadoEditarChamada';
          }catch(e){
            return false;
          }
        }
      ).timeout(const Duration(seconds: 10));

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));
      final resultado = responseJson['resultado'];

        if(resultado == true || resultado == 'true'){
          if(mounted) showSuccessSnackBar('Presenças editadas com sucesso.', context);
          _mudancasSalvas = true;
          return true;
        }
      return false;
    }on TimeoutException{
      print("Erro: Tempo de resposta para editar lista");
      if(mounted) showErrorSnackBar('Tempo de resposta esgotado para editar lista.', context);
      return false;
    }catch(e){
      print("Erro ao editar lista: $e");
      if(mounted) showErrorSnackBar('Erro ao editar lista: $e', context);
      return false;
    }
  }

  Future<bool> _deletarChamada() async{
    Map<String, dynamic> jsonDeletarChamada = {
      "operacao" : "DeletarChamada",
      "codigoChamada" : widget.idChamada,
    };

    try{
      setState(() {
        _carregando = true;
        _erro = null;
      });

      _socketService.send(jsonDeletarChamada);

      final responseData = await _socketService.messages.firstWhere(
        (data) {
          try{
            final message = jsonDecode(data is String ? data : utf8.decode(data));
            return message['operacao'] == 'ResultadoDeletarChamada';
          }catch(e){
            return false;
          }
        }
      ).timeout(const Duration(seconds: 10));

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));
      final resultado = responseJson['resultado'];

      if(mounted){
        setState(() {
          _carregando = false;
        });
      }

        if(resultado == true || resultado == 'true'){
          if(mounted) showSuccessSnackBar('Chamada excluída com sucesso.', context);
          _mudancasSalvas = true;
          return true;
        }
        if(mounted) showErrorSnackBar('Erro ao excluir chamada.', context);
      return false;
    }on TimeoutException{
      print("Erro: Tempo de resposta para deletar chamada");
      if(mounted) {
        setState(() {
          _carregando = false;
        });
        showErrorSnackBar('Tempo de resposta esgotado para excluir chamada.', context);
      }
      return false;
    }catch(e){
      print("Erro ao deletar chamada: $e");
      if(mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Erro ao excluir chamada: $e';
        });
        showErrorSnackBar('Erro ao excluir chamada: $e', context);
      }
      return false;
    }
  }
}