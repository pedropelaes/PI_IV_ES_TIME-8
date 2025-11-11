import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vocattio/models/loc_padrao.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/screens/alunos_turma_screen.dart';
import 'package:vocattio/screens/tela_presencas.dart';
import 'package:vocattio/screens/abrir_chamada_screen.dart';
import 'package:vocattio/screens/validate_attendance_screen.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/dialog_exc.dart';
import 'package:vocattio/widgets/animated_button.dart';
import 'package:vocattio/utils/responsive_helper.dart';
import 'package:vocattio/widgets/forms_dialog.dart';
import 'package:vocattio/widgets/location_picker.dart';
import 'package:vocattio/widgets/slide_up_card.dart';
import 'package:vocattio/widgets/snackbars.dart';
import 'package:vocattio/widgets/app_drawer.dart'; 
import 'package:vocattio/widgets/text_field.dart';

class DetalhesTurmaScreen extends StatefulWidget {
  final String nomeTurma;
  final String descricao;
  final int numeroAlunos;
  final String codigoTurma;
  final String turmaId;
  final LocPadrao locPadrao;
  final User user;

  const DetalhesTurmaScreen({
    super.key,
    required this.nomeTurma,
    required this.descricao,
    required this.numeroAlunos,
    required this.codigoTurma,
    required this.turmaId,
    required this.locPadrao,
    required this.user,
  });

  @override
  State<DetalhesTurmaScreen> createState() => _DetalhesTurmaScreenState();
}

class _DetalhesTurmaScreenState extends State<DetalhesTurmaScreen> {
  final SocketService _socketService = getIt<SocketService>();

  late LocPadrao _editedLocPadrao;
  bool _isLoadingEdit = false;

  final TextEditingController editNameController = TextEditingController();
  final TextEditingController editDescController = TextEditingController();

  @override void initState() {
    super.initState();
    editNameController.text = widget.nomeTurma;
    editDescController.text = widget.descricao;
    _editedLocPadrao = widget.locPadrao;
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    Future<bool?> _editarTurma() async {
    setState(() {
      _isLoadingEdit = true;
    });

    Map<String, dynamic> jsonEditarTurma = {
      "operacao": "EditarTurma",
      "turmaId": widget.turmaId,
      "nome": editNameController.text, // Usa o controller
      "descricao": editDescController.text, // Usa o controller
      "locPadrao": _editedLocPadrao.toJson() // Usa o estado _editedLocPadrao
    };

    try {
      _socketService.send(jsonEditarTurma);

      final responseData = await _socketService.messages.firstWhere(
        (data) {
          try {
            final message = jsonDecode(data is String ? data : utf8.decode(data));
            // Assumindo que a resposta será 'ResultadoEditarTurma'
            return message['operacao'] == 'ResultadoEditarTurma';
          } catch (e) {
            return false;
          }
        },
      ).timeout(const Duration(seconds: 10));

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));
      final resultado = responseJson['resultado'];

      return (resultado == 'true' || resultado == true);

    } on TimeoutException {
      print("Erro: Tempo de resposta para editar turma");
      return null;
    } catch (e) {
      print("Erro ao editar turma: $e");
      return null;
    } finally {
      setState(() {
        _isLoadingEdit = false;
      });
    }
  }

    return Scaffold(
      key: _scaffoldKey, 
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: widget.nomeTurma,
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer(); 
        },
        hasGoBack: true,
        onGoBack: () {
          Navigator.pop(context);
        },
      ),
      drawer: AppDrawer(
        user: widget.user,
        currentTurmaId: widget.turmaId,
      ), 
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.isDesktop(context) ? 600 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Código da turma
                  primaryFixedGradientContainer(
                    width: double.infinity,
                    padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 24 : 20),
                    theme: theme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Código da Turma',
                              style: textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primaryFixed,
                                fontWeight: FontWeight.bold,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                              ),
                            ),
                            if(widget.user.tipo == 'professor')
                            IconButton(
                              onPressed: (){
                                editNameController.text = widget.nomeTurma;
                                editDescController.text = widget.descricao;
                                setState(() {
                                  _editedLocPadrao = widget.locPadrao;
                                });

                                if(!kIsWeb){
                                  showModalBottomSheet(
                                    context: context, 
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    isDismissible: false,
                                    enableDrag: false,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft:Radius.circular(20), topRight: Radius.circular(20))),
                                    builder: (BuildContext context){
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
                                        child: DraggableScrollableSheet(
                                          initialChildSize: 0.85,
                                          minChildSize: 0.6,
                                          maxChildSize: 0.95,
                                          expand: false,
                                          builder: (context, scrollController) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context, StateSetter dialogSetState){
                                                return SlideUpContainer(
                                                  content: [
                                                    SingleChildScrollView(
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(maxWidth: 400),
                                                        child: primaryFixedGradientContainer(
                                                          theme: theme,
                                                          padding: EdgeInsets.all(24.0),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: _buildFormWidgets(
                                                              context: context, 
                                                              theme: theme, 
                                                              textTheme: textTheme,
                                                              dialogSetState: dialogSetState, 
                                                              onConfirm: () async{
                                                                await _editarTurma();
                                                              }
                                                            )
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                  theme: theme
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  );
                                }else{
                                  showFormsDialog(
                                    context, 
                                    (dialogSetState) => _buildFormWidgets(context: context, theme: theme, textTheme: textTheme, 
                                      dialogSetState: dialogSetState, 
                                      onConfirm: () async{
                                        await _editarTurma();
                                      }
                                    )
                                  );
                                } 
                              },
                              icon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primaryFixed,
                              )
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.codigoTurma,
                          style: textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primaryFixed,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.descricao,
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primaryFixed.withValues(alpha: 0.9),
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? 50 : 40),
                  
                  // Botões de ação
                  Expanded(
                    child: ListView(
                      children: [

                        widget.user.tipo == 'professor' ? AnimatedButton(
                          text: 'Realizar chamada',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GerarQRCodeScreen(
                                  // Para abrir chamada no backend, usa-se o ObjectId da turma
                                  codigoTurma: widget.turmaId,
                                ),
                              ),
                            );
                          },
                        )
                        : AnimatedButton(
                          text: 'Registrar Presença',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ValidateAttendanceScreen(uid: widget.user.uid),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        AnimatedButton(
                          text: 'Ver Presenças',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PresencasScreen(
                                  nomeTurma: widget.nomeTurma,
                                  turmaId: widget.turmaId,
                                  userType: widget.user.tipo,
                                  userId: widget.user.objectId!,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if(widget.user.tipo == 'professor') AnimatedButton(
                          text: 'Exportar Lista de Presença',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de exportação será implementada'),
                              ),
                            );
                          },
                        ),
                        
                        if(widget.user.tipo == 'professor') const SizedBox(height: 16),
                        
                        if(widget.user.tipo == 'professor') AnimatedButton(
                          text: 'Relatório Mensal',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade de relatório será implementada'),
                              ),
                            );
                          },
                        ),
                        
                        if(widget.user.tipo == 'professor') const SizedBox(height: 16),
                        
                        AnimatedButton(
                          text: 'Alunos',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlunosTurmaScreen(
                                  nomeTurma: widget.nomeTurma, 
                                  turmaId: widget.turmaId
                                )
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: widget.user.tipo == 'professor' ? FloatingActionButton(
        backgroundColor: theme.colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
        onPressed: () async {
          final confirm = await showCustomDialog(
            context, 
            Icons.delete_forever,
            'Deseja apagar essa turma?',
            'Não será possível restaurar essa turma, deve ter certeza que deseja excluir permanentemente.',
            () async {
              bool? apagarTurmaResult = await _apagarTurma();
              if(apagarTurmaResult == true){
                if(mounted) showSuccessSnackBar('Turma apagada.', context);
                Navigator.of(context).pop(true);
              }else if (apagarTurmaResult == null){
                if(mounted) showErrorSnackBar("Erro ao apagar turma.", context);
              }else{
                if(mounted) showErrorSnackBar("Permissão negada.", context);
              }
            },
            'Apagar',
            isCritical: true,
          );

          if (confirm == true) {
            showSuccessSnackBar('Turma excluída com sucesso!', context);
            Navigator.of(context).pop(true);
          }
        },
      )  : null
    );
  }


  Future<bool?> _apagarTurma() async {
  Map<String, dynamic> jsonApagarTurma = {
    "operacao" : "ApagarTurma",
    "turmaId" : widget.turmaId,
    "professorId" : widget.user.objectId
  };

  try{
    _socketService.send(jsonApagarTurma);

    final responseData = await _socketService.messages.firstWhere(
      (data){
        try{
          final message = jsonDecode(data is String ? data : utf8.decode(data));
          return message['operacao'] == 'ResultadoApagarTurma';
        }catch(e){
          return false;
        }
      }
    ).timeout(const Duration(seconds: 10));

    final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));
    final resultado = responseJson['resultado'];

    print("Resposta de apagar turma: $resultado");

    if(resultado == 'true' || resultado == true){
      return true;
    }else{
      return false;
    }

  }on TimeoutException{
    print("Erro: Tempo de resposta para apagar turma");
    return null;
  }catch(e){
    print("Erro ao apagar turma: $e");
    return null;
  }
}

List<Widget> _buildFormWidgets({
  required BuildContext context,
  required ThemeData theme,
  required TextTheme textTheme,
  required StateSetter dialogSetState,
  required VoidCallback onConfirm
}){
  return [
    Text(
      "Editar Turma",
      style: textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.primaryFixed,
      ),
    ),
    SizedBox(height: 18),
    TextFieldDesign(
      controller: editNameController,
      hintText: 'Nome da Turma',
      context: context,
    ),
    SizedBox(height: 12),
    TextFieldDesign(
      controller: editDescController,
      hintText: 'Descrição',
      context: context,
    ),
    SizedBox(height: 12,),
    Text(
      "Editar local padrão",
      style: textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.primaryFixed,
      ),
    ),
    SizedBox(height: 12),
    LocationPickerWidget(
      initialLocation: LatLng(
        _editedLocPadrao.latitude,
        _editedLocPadrao.longitude),
        onLocationChanged: (newLocation) {
        dialogSetState(() { 
          _editedLocPadrao = LocPadrao(
            latitude: newLocation.latitude,
            longitude: newLocation.longitude,
          );
        });
      },
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            "Cancelar",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.secondaryFixed
            ),
          ),
        ),
        SizedBox(height: 12,),
        TextButton(
          onPressed: () async {
            if (_isLoadingEdit) return;
                                                    
            final resultado = onConfirm;
            
            if (mounted) {
              Navigator.pop(context); // Fecha o modal
            }
            
            if (resultado == true && mounted) {
              showSuccessSnackBar("Turma editada! Recarregando...", context);
              Navigator.of(context).pop();
            } else if (mounted) {
              showErrorSnackBar("Erro ao editar turma.", context);
            }
          },
          child: Text(
            "Confirmar",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primaryFixed,
            ),
          ),
        ),
      ],
    ),
  ];
}
}