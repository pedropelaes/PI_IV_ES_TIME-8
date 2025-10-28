import 'package:flutter/material.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/screens/criar_turma_screen.dart';
import 'package:vocattio/screens/entrar_em_turma_screen.dart';

class CustomFAB extends StatelessWidget {
  final String tipo;
  final String objectId;
  final VoidCallback? onPressed;
  final IconData icon;

  const CustomFAB({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
    required this.tipo,
    required this.objectId
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return FloatingActionButton(
      onPressed: onPressed ?? () {
        tipo == "professor"?
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CriarTurmaScreen(objectId: objectId,)),
        ):Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EntrarEmTurmaScreen(objectId: objectId,)),
        );
      },
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4,
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}
