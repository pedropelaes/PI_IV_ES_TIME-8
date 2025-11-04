import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vocattio/services/location/location_service.dart'; 
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';
import 'package:vocattio/widgets/snackbars.dart';

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
  final LocationService _locationService = LocationService();
  
  LatLng _selectedLocation = const LatLng(-22.9068, -47.0616); // campinas padrao

  @override
  void dispose(){
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
  
  @override
  void initState(){
    super.initState();
    _locationService.checkLocationPermission();
  }

  Future<void> _showLocationPickerDialog() async {
    LatLng dialogSelectedLocation = _selectedLocation;
    final Set<Marker> dialogMarkers = {};
    GoogleMapController? dialogMapController;
    bool isDialogMapLoading = true;

    final TextEditingController dialogLatController = TextEditingController();
    final TextEditingController dialogLonController = TextEditingController();

    void updateDialogState(LatLng location, Function dialogSetState) {
      dialogSelectedLocation = location;
      dialogMarkers.clear();
      dialogMarkers.add(
        Marker(
          markerId: const MarkerId("selected_location"),
          position: location,
          draggable: true,
          onDragEnd: (newPosition) {
            updateDialogState(newPosition, dialogSetState);
          },
        ),
      );
      dialogLatController.text = location.latitude.toStringAsFixed(6);
      dialogLonController.text = location.longitude.toStringAsFixed(6);
      
      // Atualiza o estado do dialog
      dialogSetState(() {});
    }

    // Função para carregar a localização inicial *do dialog*
    Future<void> defLocInicialDoMapaDialog(Function dialogSetState) async {
      Position? posRapida = await LocationService.obterPosicaoInicialRapida();
      LatLng localInicial = (posRapida != null)
          ? LatLng(posRapida.latitude, posRapida.longitude)
          : _selectedLocation; // Usa a localização já salva como ponto de partida

      updateDialogState(localInicial, dialogSetState);
      dialogMapController?.animateCamera(CameraUpdate.newLatLngZoom(localInicial, 15.0));
      dialogSetState(() { isDialogMapLoading = false; });
    }

    final theme = Theme.of(context);

    final bool? locationWasSaved = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: primaryFixedGradientContainer(
                  theme: theme,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 20.0),
                        child: Text(
                          "Selecionar Local Padrão",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primaryFixed,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: theme.colorScheme.outline),
                                ),
                                height: 300,
                                width: 400, 
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: dialogSelectedLocation,
                                        zoom: 15.0
                                      ),
                                      onMapCreated: (controller) {
                                        dialogMapController = controller;
                                        defLocInicialDoMapaDialog(dialogSetState);
                                      },
                                      onTap: (pos) => updateDialogState(pos, dialogSetState),
                                      markers: dialogMarkers,
                                      myLocationButtonEnabled: false,
                                      myLocationEnabled: true,
                                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                                        Factory<EagerGestureRecognizer>(
                                          () => EagerGestureRecognizer()
                                        )
                                      },
                                    ),
                                    if(isDialogMapLoading)
                                      CircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    Positioned(
                                      top: 16.0,
                                      right: 16.0,
                                      child: FloatingActionButton(
                                        mini: true,
                                        onPressed: () async {
                                          dialogSetState(() { isDialogMapLoading = true; });
                                          try {
                                            final position = await ValidadorLocalizacao.obterPosicaoAtual();
                                            if (position != null) {
                                              final newPos = LatLng(position.latitude, position.longitude);
                                              updateDialogState(newPos, dialogSetState);
                                              dialogMapController?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 17.0));
                                            } else {
                                              if(mounted) showErrorSnackBar('Erro ao obter localização atual', context);
                                            }
                                          } catch (e) {
                                            if(mounted) showErrorSnackBar('Não foi possivel obter localização precisa', context);
                                          } finally {
                                            dialogSetState(() { isDialogMapLoading = false; });
                                          }
                                        },
                                        child: const Icon(Icons.my_location),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Ou digite manualmente', 
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.primaryFixed
                                )
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFieldDesign(
                                      controller: dialogLatController, 
                                      hintText: 'Latitude', 
                                      context: context
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFieldDesign(
                                      controller: dialogLonController, 
                                      hintText: 'Longitude', 
                                      context: context
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                
                      Padding(
                        padding: const EdgeInsets.all(8.0), 
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                "Cancelar",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.secondaryFixed
                                ),
                              ),
                            ),
                            SizedBox(height: 18,),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLocation = dialogSelectedLocation;
                                });
                                Navigator.of(context).pop(true);
                            }, 
                              child: Text(
                                "Salvar Local",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.primaryFixed
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  Future<bool?> _criarTurma() async {
    // Validação
    if (nameController.text.isEmpty) {
      showErrorSnackBar("Por favor, insira um nome para a turma.", context);
      return false;
    }

    Map<String, dynamic> jsonCriarTurma = {
      "operacao": "CriarTurma",
      "nome": nameController.text,
      "descricao": descriptionController.text,
      "objectId": widget.objectId,
      "localizacaoPadrao": {
        "latitude": _selectedLocation.latitude,
        "longitude": _selectedLocation.longitude
      }
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

      return (resultado == 'true' || resultado == true);

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
    final textTheme = theme.textTheme;

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
                          width: 100,
                          height: 100,
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
                
                      TextFieldDesign(controller: descriptionController, hintText: 'Descrição da turma (opcional)', context: context),
                      SizedBox(height: largeSpacing),

                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200, maxWidth: 400),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Localização Padrão (Fallback)',
                              style: textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Tooltip(
                              message: 'Localização usada para validação caso não seja possivel coletar a sua localização na hora da aula.',
                              child: Icon(
                                Icons.help_outline,
                                size: 20,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200, maxWidth: 400),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.colorScheme.outline),
                          ),
                          leading: Icon(Icons.map, color: theme.colorScheme.primary),
                          title: Text(
                            'Escolher localização de segurança',
                            style: textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            'Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation.longitude.toStringAsFixed(4)}',
                          ),
                          trailing: Icon(Icons.edit, color: theme.colorScheme.primary),
                          onTap: _showLocationPickerDialog, // <-- CHAMA O DIALOG
                        ),
                      ),
                      // --- FIM DA MUDANÇA ---
                
                      SizedBox(height: largeSpacing),
                      primaryButtonDesign(
                        context: context,
                        label: 'Criar Turma',
                        width: 255,
                        height: 55.0,
                        onTap: () async {
                          // --- MUDANÇA: A lógica de salvar agora é esta ---
                          final resultado = await _criarTurma();
                          if (resultado == true && mounted) {
                            showSuccessSnackBar("Turma Criada!", context);
                            Navigator.of(context).pop(true);
                            
                          } else if (resultado == false && mounted) {
                            showErrorSnackBar("Erro ao criar turma", context);
                          } else if (mounted) {
                            showErrorSnackBar("Erro de conexão", context);
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