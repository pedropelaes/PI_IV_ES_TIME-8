import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vocattio/theme/theme.dart';
import 'package:vocattio/theme/theme_notifier.dart';
import 'package:vocattio/theme/util.dart';
import 'package:vocattio/widgets/app_header.dart';

class ScanQrcode extends StatefulWidget {
  const ScanQrcode({super.key});

  @override
  State<ScanQrcode> createState() => _ScanQrcodeState();
}

class _ScanQrcodeState extends State<ScanQrcode> {
  final TextEditingController _codeController = TextEditingController();
  bool _scanned = false;

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
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
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
                    child: MobileScanner(
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
                    ),
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

                  // Botão de concluir
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final code = _codeController.text.trim();
                        if (code.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Digite ou escaneie um código.'),
                              backgroundColor: theme.colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Presença registrada: $code'),
                            backgroundColor: theme.colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Concluir chamada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
      