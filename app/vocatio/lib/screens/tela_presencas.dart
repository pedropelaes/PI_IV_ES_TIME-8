import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';

class PresencasScreen extends StatefulWidget {
  final String? codigoChamada;
  final String? nomeTurma;
  final String? turmaId;

  const PresencasScreen({
    super.key,
    this.codigoChamada,
    this.nomeTurma,
    this.turmaId,
  });

  @override
  State<PresencasScreen> createState() => _PresencasScreenState();
}

class _PresencasScreenState extends State<PresencasScreen> {
  DateTime? _selectedDate;
  final SocketService _socketService = getIt<SocketService>();
  List<String> _alunosPresentes = [];
  bool _carregando = false;
  String? _erro;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (_, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getDateText() {
    if (_selectedDate == null) {
      return 'Selecione a Data';
    }
    return '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
  }

  @override
  void initState() {
    super.initState();
    if (widget.codigoChamada != null || widget.turmaId != null) {
      _buscarPresencas();
    }
  }

  Future<void> _buscarPresencas() async {
    if ((widget.codigoChamada == null || widget.codigoChamada!.isEmpty) &&
        (widget.turmaId == null || widget.turmaId!.isEmpty)) {
      setState(() {
        _erro = 'Código da chamada ou ID da turma não fornecido';
        _carregando = false;
      });
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
      _alunosPresentes = [];
    });

    final jsonGetPresencas = {
      "operacao": "GetPresencas",
      if (widget.codigoChamada != null && widget.codigoChamada!.isNotEmpty)
        "codigoChamada": widget.codigoChamada,
      if (widget.turmaId != null && widget.turmaId!.isNotEmpty)
        "turmaId": widget.turmaId,
    };

    try {
      _socketService.send(jsonGetPresencas);

      final responseData = await _socketService.messages
          .firstWhere((data) {
            try {
              final message = jsonDecode(data is String ? data : utf8.decode(data));
              return message['operacao'] == 'ResultadoGetPresencas';
            } catch (e) {
              return false;
            }
          })
          .timeout(const Duration(seconds: 10));

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));

      if (mounted) {
        setState(() {
          _carregando = false;
          if (responseJson['resultado'] == true && responseJson['alunos'] != null) {
            _alunosPresentes = List<String>.from(responseJson['alunos']);
          } else {
            _alunosPresentes = [];
            _erro = 'Nenhum aluno presente encontrado';
          }
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Tempo de resposta esgotado';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Erro ao buscar presenças: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppHeader(
        title: 'Presenças',
        onMenuPressed: () {
        },
        hasGoBack: true,
        onGoBack: () {
          Navigator.pop(context);
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

                Widget _listaPresencas = 
                primaryFixedGradientContainer(
                width: double.maxFinite,
                theme: theme,
                child: _carregando
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primaryFixed,
                          ),
                        ),
                      )
                    : _erro != null
                        ? Center(
                            child: Padding(
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
                            ),
                          )
                        : _alunosPresentes.isEmpty
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
                                        'Nenhum aluno presente',
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.primaryFixed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _alunosPresentes.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      _alunosPresentes[index],
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.primaryFixed,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primaryFixed,
                                    ),
                                  );
                                },
                              ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.nomeTurma ?? 'Presenças',
                    style: textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface
                    ),
                  ),
                  SizedBox(height: smallSpacing,),
                  Expanded(
                    child: isLargeScreen ? Center(
                      child: SizedBox(
                        width: 1000,
                        child: _listaPresencas,
                      ),
                    )
                    : _listaPresencas
                  ),
                  SizedBox(height: smallSpacing),
                  onPrimaryStyleButtonDesign(
                    context: context, 
                    label: Text(_getDateText(), style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primaryFixedDim)),
                    icon: Icons.calendar_month_outlined, 
                    onTap: () => _selectDate(context),
                    width: 255,
                    height: 55
                  ),
                  SizedBox(height: smallSpacing),
                  if (widget.codigoChamada != null || widget.turmaId != null)
                    primaryButtonDesign(
                      context: context, 
                      label: 'Atualizar', 
                      onTap: () {
                        _buscarPresencas();
                      }, 
                      width: 255, 
                      height: 55
                    ),
                  SizedBox(height: largeSpacing,),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

}
