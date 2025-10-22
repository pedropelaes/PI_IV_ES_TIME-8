import 'package:flutter/material.dart';
import 'package:vocattio/screens/scan_qrcode.dart';
import 'package:vocattio/screens/via_code.dart';
import 'package:vocattio/utils/responsive_helper.dart';
import 'package:vocattio/widgets/animated_button.dart';
import 'package:vocattio/widgets/app_header.dart';

class ValidateAttendanceScreen extends StatelessWidget {
  const ValidateAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.isDesktop(context) ? 600 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícone central
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
                    const SizedBox(height: 24),
                
                    // Título
                    Text(
                      'Registrar Presença',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        fontSize: 22
                      ),
                    ),
                    const SizedBox(height: 8),
                
                    // Texto descritivo
                    Text(
                      'Escaneie ou digite o código para validar sua presença',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AnimatedButton(
                      text: 'Via QR Code',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanQrcode(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    AnimatedButton(
                      text: 'Via Código',
                      onPressed: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViaCode(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
