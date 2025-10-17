import 'package:flutter/material.dart';
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
            
                // Botão de registrar
                const SizedBox(height: 16),
                        AnimatedButton(
                          text: 'Via QR Code',
                          onPressed: () {
                  },
                ),
            
                const SizedBox(height: 12),
                        AnimatedButton(
                          text: 'Via Código',
                          onPressed: () {
                  },
                ),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
