import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomeStudentScreen extends StatefulWidget{
  const HomeStudentScreen({super.key});

  @override
  State<HomeStudentScreen> createState() => _HomeStudentScreenState();
}

class _HomeStudentScreenState extends State<HomeStudentScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return PlatformScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 15,),
                Text(
                  'Turmas',
                  style: textTheme.headlineSmall,
                ),
                SizedBox(height: 30,),
          
                // Adicionando botões
                 _buildTurmaButton('Turma A'),
                SizedBox(height: 10),
                 _buildTurmaButton('Turma B'),

                 _buildAddTurmaButton(() {
                  // ação ao clicar no botão +
                  // exemplo: abrir diálogo de nova turma
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Nova Turma'),
                      content: const Text('Aqui você pode criar uma nova turma!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fechar'),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTurmaButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: PlatformElevatedButton(
        onPressed: () {
          // ação ao clicar na turma
        },
        color: const Color(0xFF5C4A8A),
        padding: const EdgeInsets.symmetric(vertical: 8),
        material: (_, __) => MaterialElevatedButtonData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C4A8A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
          ),
        ),
        cupertino: (_, __) => CupertinoElevatedButtonData(
        color: const Color(0xFF5C4A8A),
        borderRadius: BorderRadius.circular(6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Align(
        alignment: Alignment.centerLeft, // Alinha o texto à esquerda
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    ),
  );
}
Widget _buildAddTurmaButton(VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    child: PlatformElevatedButton(
      onPressed: onPressed,
      color: const Color(0xFF5C4A8A),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      material: (_, __) => MaterialElevatedButtonData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C4A8A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
          alignment: Alignment.center, // botão centralizado
        ),
      ),
      cupertino: (_, __) => CupertinoElevatedButtonData(
        color: const Color(0xFF5C4A8A),
        borderRadius: BorderRadius.circular(6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Adicionar Turma',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    ),
  );
}
}
