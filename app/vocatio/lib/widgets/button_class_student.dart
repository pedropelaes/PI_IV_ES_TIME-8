import 'package:flutter/material.dart';

class TurmaButton extends StatelessWidget {
  final String nomeTurma;
  final VoidCallback onTap;
  final String? subtitulo; // opcional

  const TurmaButton({
    Key? key,
    required this.nomeTurma,
    required this.onTap,
    this.subtitulo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(12), // espaço interno
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              nomeTurma,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitulo!,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
            // você pode adicionar mais widgets aqui embaixo
          ],
        ),
      ),
    );
  }
}
