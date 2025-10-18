import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vocattio/widgets/app_header.dart';
import 'package:vocattio/widgets/button_design.dart';

class ScanQrcode extends StatefulWidget {
  const ScanQrcode({super.key});

  @override
  State<ScanQrcode> createState() => _ScanQrcodeState();
}

class _ScanQrcodeState extends State<ScanQrcode> {
  final TextEditingController _codeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _scannerController.dispose(); 
    _codeController.dispose();
    super.dispose();
  }

    bool get hasScanner =>
      kIsWeb || Platform.isAndroid || Platform.isIOS;

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
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Título principal
                  Text(
                    'Aponte a câmera para o QR Code',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Área da câmera
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: hasScanner ? MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        if (_scanned) return;
                        _scanned = true;
                        final barcode = capture.barcodes.first.rawValue ?? '';
                        setState(() => _codeController.text = barcode);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('QR Code lido: $barcode'),
                            backgroundColor: theme.colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ) : Row()
                  ),

                  const SizedBox(height: 16),

                  // Campo de texto
                  TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Digite o código temporário',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  primaryButtonDesign(
                    context: context,
                    label: 'Concluir chamada',
                    width: double.infinity,
                    height: 55.0,
                    onTap: () {
                    },
                  ),
                ],
              ),
            ),
          );
        }
      }
      