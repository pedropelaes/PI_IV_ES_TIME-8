import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';

class ViaCode extends StatefulWidget {
  const ViaCode({super.key});

  @override
  State<ViaCode> createState() => _ViaCodeState();
}

class _ViaCodeState extends State<ViaCode> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _tempCodeController = TextEditingController();


  @override
  void dispose() {
    _tempCodeController.dispose(); 
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, 
      appBar: AppHeader(
        title: 'Registrar',
        onMenuPressed: () {
        },
        hasGoBack: true,
        onGoBack: () {
          Navigator.pop(context);
        },
      ),
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
                        // Título principal
                        Text(
                          'Digite o código e o código temporário',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
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
                          label: 'Concluir chamada',
                          width: 255,
                          height: 55.0,
                          onTap: () {
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
      