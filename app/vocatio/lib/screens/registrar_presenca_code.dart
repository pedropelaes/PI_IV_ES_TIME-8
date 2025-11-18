import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocattio/mixins/attendance_handler.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/snackbars.dart';
import 'package:vocattio/widgets/text_field.dart';
import 'dart:async';

class ViaCode extends StatefulWidget {
  final String? uid;
  
  const ViaCode({super.key, this.uid});

  @override
  State<ViaCode> createState() => _ViaCodeState();
}

class _ViaCodeState extends State<ViaCode> with AttendanceHandler {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _tempCodeController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _imagemBase64;

  CameraController? _cameraController;
  Future<void>? _initCameraFuture;
  bool _isCameraActive = false;
  bool _isCapturing = false;

  void _startWebCamera() async {
    setState(() {
      _isCameraActive = true;
      _isCapturing = false;
      _imagemBase64 = null;
    });

    try {
      List<CameraDescription> cameras = [];
      try {
        final result = await availableCameras();
        cameras = result;
      } catch (e) {
        print('Erro ao obter câmeras: $e');
        cameras = [];
      }

      if(!mounted) return;
      
      if(cameras.isEmpty){
        showErrorSnackBar("Nenhuma câmera encontrada.", context);
        setState(() { _isCameraActive = false; });
        return;
      }

      for (var cam in cameras) {
        print('Câmera encontrada: ${cam.name}');
      }

      final camera = cameras.firstWhere(
        (c) => c.name.contains('USB CAMERA'), // <-- Tenta encontrar sua câmera
        orElse: () => cameras.firstWhere( // Plano B: Pega a primeira frontal
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first, // Plano C: Pega a primeira da lista
        ),
      );
      
      _cameraController = CameraController(
        camera, 
        ResolutionPreset.high, 
        enableAudio: false
      );

      _initCameraFuture = _cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() { _isCapturing = true; });
        
        Future.delayed(const Duration(seconds: 3), () {
          _takeWebPicture();
        });

      }).catchError((e) {
        if (mounted) {
          String errorMsg = "Erro ao iniciar câmera";
          if (e.toString().contains("NotAllowedError")) {
            errorMsg = "Permissão de câmera negada. Verifique as configurações do navegador.";
          } else if (e.toString().contains("NotFoundError")) {
            errorMsg = "Nenhuma câmera encontrada no dispositivo.";
          } else if (e.toString().contains("cameraNotReadable")) {
            errorMsg = "Câmera indisponível. Tente fechar outros aplicativos que usam câmera.";
          }
          showErrorSnackBar(errorMsg, context);
          setState(() { _isCameraActive = false; });
        }
      });
      setState(() {});
    } catch (e) {
      if (mounted) {
        showErrorSnackBar("Erro inesperado: $e", context);
        setState(() { _isCameraActive = false; });
      }
    }
  }

  void _takeWebPicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final picture = await _cameraController!.takePicture();
      final bytes = await picture.readAsBytes();

      final base64String = base64Encode(bytes);
      
      setState(() {
        _imagemBase64 = base64String;
        _isCameraActive = false;
        _isCapturing = false;
      });

    } catch (e) {
      if (mounted) showErrorSnackBar("Erro ao tirar foto: $e", context);
      setState(() { _isCameraActive = false; _isCapturing = false; });
    } finally {
      _cameraController?.dispose();
      _cameraController = null;
      _initCameraFuture = null;
    }
  }

  @override
  void initState(){
    super.initState();
    initUserSession();
  }


  @override
  void dispose() {
    _tempCodeController.dispose(); 
    _codeController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }


  // Método para lidar com a conclusão da chamada
  Future<void> _handleCompleteAttendance() async {
    // Verificar se os campos estão preenchidos
    if (_codeController.text.isEmpty || _tempCodeController.text.isEmpty) {
      if(mounted) showErrorSnackBar('Por favor, preencha todos os campos.', context);
      return;
    }

    if(_imagemBase64 == null) return;

    // Envia presença ao servidor; validação de 100m ocorre no backend
    final sucesso = await registrarPresenca(
      aulaId: _codeController.text.trim(),
      codigoTemporario: _tempCodeController.text.trim(),
      imagemBase64: _imagemBase64!
    );

    if (sucesso && mounted) {
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    Widget _buildCameraOrLogo(ThemeData theme) {
    if (_isCameraActive && _initCameraFuture != null) {
      return FutureBuilder<void>(
        future: _initCameraFuture,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.onPrimary));
          }
          
          if (snapshot.connectionState == ConnectionState.done && _cameraController != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12), 
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CameraPreview(_cameraController!),

                  if (_isCapturing)
                    Container(
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Capturando...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            );
          }

          return Center(child: Text("Erro na câmera", style: TextStyle(color: theme.colorScheme.onErrorContainer)));
        },
      );
    }

    if (_imagemBase64 != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          Uint8List.fromList(base64Decode(_imagemBase64!)),
          fit: BoxFit.cover,
          width: 250,
          height: 250,
        ),
      );
    }

    return Image.asset(
      'assets/images/logo_vocatio_pequena_transparente.png',
      width: 100,
      height: 100,
      color: theme.colorScheme.onPrimary,
    );
  }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, 
      key: _scaffoldKey,
      appBar: AppHeader(
        title: 'Registrar',
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        hasGoBack: true,
        onGoBack: () {
          Navigator.pop(context);
        },
      ),
      drawer: AppDrawer(),
      body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
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
                        SizedBox(height: largeSpacing),
                        Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildCameraOrLogo(theme),
                      ),
                                      
                        SizedBox(height: largeSpacing),
                        TextFieldDesign(controller: _codeController, hintText: "Digite o código", context: context),
                        
                        SizedBox(height: smallSpacing),
                        TextFieldDesign(controller: _tempCodeController, hintText: "Digite o código temporário", context: context),
                        SizedBox(height: smallSpacing),
                        ButtonDesign(context: context, 
                          childText: _imagemBase64 == null ? 'Tirar foto' : 'Tirar foto novamente', 
                          onPressed: ()async{ 
                            if (_isCameraActive) return; 

                            if (kIsWeb) {
                              _startWebCamera(); 
                            } else {
                              final imagem = await tirarSelfie(); 
                              if (imagem != null) {
                                setState(() {
                                  _imagemBase64 = imagem;
                                });
                              }
                            }
                          }
                        ),
                        if(_imagemBase64 != null)
                          tertiaryContainer(theme: theme, 
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Foto tirada',
                            style: textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer
                            ),
                          )),
                        SizedBox(height: smallSpacing,),
                        primaryButtonDesign(
                          context: context,
                          label: isGettingLocation ? 'Obtendo localização...' : 'Registrar Presença',
                          width: 255,
                          height: 55.0,
                          onTap: isGettingLocation ? () {} : () {
                            _handleCompleteAttendance();
                          },
                        ),
                      ],
                                      ),
                    ),
                  );
                } 
              ),
            ),
          );
        }
      }
      