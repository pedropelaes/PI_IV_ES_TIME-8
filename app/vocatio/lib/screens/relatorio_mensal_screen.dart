import 'dart:async';
import 'dart:convert';

import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:vocattio/extensions/string_extensions.dart';
import 'package:vocattio/models/faltas_do_dia.dart';
import 'package:vocattio/models/relatorio_aluno.dart';
import 'package:vocattio/models/relatorio_turma.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';

class RelatorioMensalScreen extends StatefulWidget{
  final String? nomeTurma;
  final String? turmaId;
  const RelatorioMensalScreen({
    super.key,
    required this.nomeTurma,
    required this.turmaId,
  });

  @override
  State<RelatorioMensalScreen> createState() => _RelatorioMensalScreenState();
}

class _RelatorioMensalScreenState extends State<RelatorioMensalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SocketService _socketService = getIt<SocketService>();
  final User currentUser = getIt<User>();
  DateTime? _selectedDate;
  bool _carregando = false;
  String? _erro;
  RelatorioTurma? relatorioTurma;
  List<RelatorioAluno> _listaRelatorioAlunos = [];
  List<FaltasDoDia> _diasMaisFaltados = [];
  

  Future<void> _selectDate(BuildContext context, ThemeData theme) async {
    DateTime? tempDate;

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        final colorToUse = theme.colorScheme.primaryFixed;
        final contrastColor = theme.colorScheme.onPrimaryFixed;
        return Theme(
          data: theme.copyWith(
            textTheme : theme.textTheme.apply(
              bodyColor: colorToUse,
              displayColor: colorToUse,
            ),
            iconTheme: theme.iconTheme.copyWith(color: colorToUse),
            colorScheme: theme.colorScheme.copyWith(
              onSurface: colorToUse,
              primary: colorToUse,
              onPrimary: contrastColor,
              secondary: theme.colorScheme.tertiaryFixed
            )
          ),
          child: Dialog(
            backgroundColor: Colors.transparent, 
            insetPadding: EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: primaryFixedGradientContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    MonthPicker(
                      //splashColor: theme.colorScheme.primaryFixed,
                      //highlightColor: theme.colorScheme.primaryFixedDim,
                      //slidersColor: theme.colorScheme.tertiaryFixed,
                      minDate: DateTime(2020),
                      maxDate: DateTime.now(),
                      initialDate: _selectedDate ?? DateTime.now(),
                      onDateSelected: (date) {
                        tempDate = date;
                      },
                    ),
                      
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text("Cancelar"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Confirmar"),
                          onPressed: () async {
                            Navigator.of(context).pop(tempDate); 
                          },
                        ),
                      ],
                    )
                  ],
                ), theme: theme,
              ),
            ),
          ),
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _gerarRelatorioDoMes();
    }
  }

  String _getDateText() {
    if (_selectedDate == null) {
      return 'Escolher mês';
    }
    return DateFormat.MMMM('pt_BR').format(_selectedDate!).capitalize();
  }

  Future<void> _gerarRelatorioDoMes() async{
    if(widget.turmaId == null || widget.turmaId!.isEmpty || _selectedDate == null){
      setState(() {
        _erro = 'ID da turma não fornecido';
        _carregando = false;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
      relatorioTurma = null;
    });

    final jsonGetRelatorio = {
      'operacao' : 'GetRelatorioMensal',
      'turmaId' : widget.turmaId,
      'mes' : _selectedDate!.month,
      'ano' : _selectedDate!.year
    };

    try{
      _socketService.send(jsonGetRelatorio);

      final responseData = await _socketService.messages
          .firstWhere((data) {
            try {
              final message = jsonDecode(data is String ? data : utf8.decode(data));
              return message['operacao'] == 'ResultadoGetRelatorioMensal';
            } catch (e) {
              return false;
            }
          })
          .timeout(const Duration(seconds: 10));

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));

      if (mounted) {
        setState(() {
          _carregando = false;
          if (responseJson['resultado'] == true && responseJson['relatorioMensalTurma'] != null) {
            relatorioTurma = RelatorioTurma.fromJson(responseJson['relatorioMensalTurma']);

            _listaRelatorioAlunos = relatorioTurma!.alunosInfo;
            _diasMaisFaltados = relatorioTurma!.diasInfo;
            _diasMaisFaltados.sort((a, b) =>
              b.totalDeFaltas.compareTo(a.totalDeFaltas));

            if(_listaRelatorioAlunos.isEmpty){
              _erro = 'Não há nenhuma aula/presença nesse mês.';
            }
          }
        });
      }
    }on TimeoutException{
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Tempo de resposta esgotado';
        });
      }
    }catch(e){
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Erro ao buscar presenças: $e';
        });
      }
    }
  }

  @override
  void initState(){
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      key: _scaffoldKey,
      appBar: AppHeader(
        title: "Presenças do mês",
        onMenuPressed: (){
          _scaffoldKey.currentState?.openDrawer();
        },
        hasGoBack: true,
        onGoBack: () {
          Navigator.pop(context);
        },
      ),
      drawer: AppDrawer(
        user: currentUser,
        currentTurmaId: widget.turmaId,
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
              //double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);
          
              Widget listaPresencasMes = 
                primaryFixedGradientContainer(
                  theme: theme,
                  width: double.maxFinite,
                  child: _carregando
                    ? Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primaryFixed,
                        ),
                      ),
                    )
                    : _erro != null
                      ? Padding(
                        padding: const EdgeInsets.all(20.0),
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
                      )
                    : _selectedDate == null
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Selecione uma data',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.primaryFixed,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                    : _listaRelatorioAlunos.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: theme.colorScheme.primaryFixed,
                              size: 48,
                            ),
                            SizedBox(height: smallSpacing,),
                            Text(
                              'Não há presenças registradas nesse mês',
                              style: textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.primaryFixed,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                      cacheExtent: 1,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _listaRelatorioAlunos.length,
                      itemBuilder:(context, index) {
                        final relatorioAluno = _listaRelatorioAlunos[index];
                    
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 4.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Text(
                                  relatorioAluno.alunoNome,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primaryFixed
                                  ),
                                ),
                                title: Text(
                                  '${relatorioAluno.totalDeFaltas} ${relatorioAluno.totalDeFaltas == 1 ? "falta" : "faltas"}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primaryFixed
                                  ),
                                ),
                                trailing: Text(
                                  '${(relatorioAluno.porcentagemPresenca * 100).toStringAsFixed(0)}%',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primaryFixed
                                  ),
                                ),
                              ),
                              if(index + 1 != _listaRelatorioAlunos.length)
                              Divider(
                                color: theme.colorScheme.primaryFixed,
                                thickness: 2,
                              )
                            ].animate().flipH(perspective: !isLargeScreen ? -0.5 : 0, begin: 0.3).fadeIn(),
                          ),
                        );
                      },
                    )
                );
          
                Widget containerMediaPresenca = 
                tertiaryGradientContainer(
                  theme: theme, 
                  right: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Média de presença',
                          style: textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primaryFixed
                          ),
                        ),
                        SizedBox(height: smallSpacing,),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        value: relatorioTurma?.mediaDaTurma ?? 0.0, 
                                        strokeWidth: 6.0,
                                        backgroundColor: theme.colorScheme.primaryFixed.withValues(alpha: 0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.primaryFixed,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: smallSpacing),
                                    Text(
                                      '${((relatorioTurma?.mediaDaTurma ?? 0.0)*100).toStringAsFixed(0)}%',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.primaryFixed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: smallSpacing),
                              Expanded(
                                child: Text(
                                  '${relatorioTurma?.totalDeFaltas ?? 0} ${relatorioTurma?.totalDeFaltas == 1 ? "falta" : "faltas"}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primaryFixed
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                  )
                );
          
                Widget containerDiasMaisFaltados = tertiaryGradientContainer(
                  theme: theme,
                  right: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Dias mais faltados',
                          style: textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primaryFixed,
                          ),
                        ),
                        SizedBox(height: smallSpacing),
                        Expanded(
                          child: SizedBox(
                            height: 60, 
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                if (_diasMaisFaltados.isNotEmpty) ...[
                                  Text(
                                    '${_diasMaisFaltados.first.diaDasemana}: '
                                    '${_diasMaisFaltados.first.totalDeFaltas}',
                                    style: textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.primaryFixed.withOpacity(0.95),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                          
                                ..._diasMaisFaltados.skip(1).map((faltas) {
                                  final nomeDia = faltas.diaDasemana;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Divider(
                                          color: theme.colorScheme.primaryFixed.withOpacity(0.4),
                                          thickness: 1,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '$nomeDia: ${faltas.totalDeFaltas}',
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: theme.colorScheme.primaryFixed.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
          
                Widget containersRow = 
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: containerMediaPresenca),
                      SizedBox(width: smallSpacing,),
                      Expanded(child: containerDiasMaisFaltados)
                    ],
                  );
          
              final double viewportHeight = constraints.maxHeight;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.nomeTurma ?? "Presenças do mês",
                        style: textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: smallSpacing,),
                    onPrimaryStyleButtonDesign(
                      context: context, 
                      label: Text(_getDateText(), style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primaryFixedDim)),
                      icon: Icons.calendar_month_outlined, 
                      onTap: () => _selectDate(context, theme),
                      width: 350,
                      height: 55
                    ),
                    SizedBox(height: smallSpacing,),
                    SizedBox(
                        height: (viewportHeight * 0.5).clamp(300.0, 700.0),
                        child: isLargeScreen ? Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 1000), 
                            child: listaPresencasMes,
                          ),
                        )
                        : listaPresencasMes,
                      ),
                  SizedBox(height: smallSpacing,),
                  isLargeScreen ? SizedBox(
                    width: 1000,
                    height: 150,
                    child: containersRow
                  )
                  : SizedBox(
                    height: 150,
                    child: containersRow
                    )
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}