import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vocattio/mixins/attendance_handler.dart';
import 'package:vocattio/services/location/location_service.dart';
import 'package:vocattio/widgets/app_drawer.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/snackbars.dart';
import 'package:vocattio/widgets/text_field.dart';
import 'dart:async';
import 'dart:convert';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/models/user.dart';

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

  @override
  void initState(){
    super.initState();
    //locationService.checkLocationPermission();
    initUserSession();
  }


  @override
  void dispose() {
    _tempCodeController.dispose(); 
    _codeController.dispose();
    super.dispose();
  }


  // Método para lidar com a conclusão da chamada
  Future<void> _handleCompleteAttendance() async {
    // Verificar se os campos estão preenchidos
    if (_codeController.text.isEmpty || _tempCodeController.text.isEmpty) {
      if(mounted) showErrorSnackBar('Por favor, preencha todos os campos.', context);
      return;
    }

    // Obter a localização atual
    final location = await getCurrentLocation();

    // Envia presença ao servidor; validação de 100m ocorre no backend
    final sucesso = await registrarPresenca(
      aulaId: _codeController.text.trim(),
      codigoTemporario: _tempCodeController.text.trim()
    );

    if (sucesso && mounted) {
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

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
                        child: Image.asset(
                          'assets/images/logo_vocatio_pequena_transparente.png',
                          width: 100,
                          height: 100,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                                      
                        SizedBox(height: largeSpacing),
                        TextFieldDesign(controller: _codeController, hintText: "Digite o código", context: context),
                        SizedBox(height: smallSpacing),
                        TextFieldDesign(controller: _tempCodeController, hintText: "Digite o código temporário", context: context),
                        SizedBox(height: largeSpacing),
                                      
                        primaryButtonDesign(
                          context: context,
                          label: isGettingLocation ? 'Obtendo localização...' : 'Concluir chamada',
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
      