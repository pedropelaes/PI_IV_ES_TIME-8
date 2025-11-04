import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vocattio/models/presenca.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';

class TelaAlunosPresentes extends StatefulWidget{
  final String idChamada;
  final String nomeTurma;
  final String data;
  final List<Presenca> alunosPresentes;
  const TelaAlunosPresentes({super.key, required this.idChamada, required this.nomeTurma ,required this.data, required this.alunosPresentes});

  @override
  State<TelaAlunosPresentes> createState() => _TelaAlunosPresentesState();
}

class _TelaAlunosPresentesState extends State<TelaAlunosPresentes> {
  final SocketService _socketService = getIt<SocketService>();
  final List<Presenca> _alunosPresentes = [];
  bool _carregando = false;
  bool _editando = false;
  String? _erro;


  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if(widget.alunosPresentes.isNotEmpty && _alunosPresentes.isEmpty){
      _alunosPresentes.addAll(widget.alunosPresentes);
    }

    return Scaffold(
      appBar: AppHeader(
        title: widget.nomeTurma,
        hasGoBack: true,
        onMenuPressed: (){

        },
        onGoBack: (){
          Navigator.pop(context);
        },
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
              double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);        

              Widget _listaPresentes = 
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
                          Widget trailingIcon; 
                          if(aluno.presente ){
                            trailingIcon = Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primaryFixed,
                            );
                          }else{
                            trailingIcon = Icon(
                              Icons.cancel,
                              color: theme.colorScheme.error,
                            );
                          }
                          
                
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                ).animate().flipH(perspective: -0.5, begin: 0.3).fadeIn(),
                                Divider(
                                  color: theme.colorScheme.primaryFixed,
                                  thickness: 2,
                                )
                              ],
                            ),
                          );
                        },
                      )
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
                        child: _listaPresentes,
                      ),
                    )
                    : _listaPresentes
                  ),
                  SizedBox(height: smallSpacing,),
                  if(!_editando)
                  primaryButtonDesign(
                    context: context, 
                    label: 'Editar lista de presença', 
                    onTap: (){
                      setState(() {
                        _editando = true;
                      });
                      // tornar lista editavel, efeito 
                    }, 
                    width: 350, 
                    height: 55
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
                          });
                        },
                        width: 150, 
                        height: 55
                      ),
                      SizedBox(width: smallSpacing,),
                      primaryButtonDesign(
                        context: context, 
                        label: 'Confirmar', 
                        onTap: (){
                          // salvar edicoes
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
    );
  }
}