import 'package:flutter/material.dart';

class DeleteFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const DeleteFAB({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () {
        // Ação padrão de deletar
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: const Text('Tem certeza que deseja excluir esta turma?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Turma excluída com sucesso!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Voltar para a tela anterior
                    Navigator.of(context).pop();
                  },
                  child: const Text('Excluir'),
                ),
              ],
            );
          },
        );
      },
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(
        Icons.delete,
        size: 24,
      ),
    );
  }
}
