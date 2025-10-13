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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      'Turmas',
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 30),
                    _buildTurmaButton('Turma A'),
                    const SizedBox(height: 10),
                    _buildTurmaButton('Turma B'),
                    const SizedBox(height: 80), // espaço pro botão flutuante
                  ],
                ),
              ),
            ),

            // Botão de adicionar turma no canto inferior direito
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildAddTurmaButton(() {
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
            ),
          ],
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
      width: 60,
      height: 60,
      child: PlatformElevatedButton(
        onPressed: onPressed,
        color: const Color(0xFF5C4A8A),
        material: (_, __) => MaterialElevatedButtonData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C4A8A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero,
            elevation: 3,
          ),
        ),
        cupertino: (_, __) => CupertinoElevatedButtonData(
          color: const Color(0xFF5C4A8A),
          borderRadius: BorderRadius.circular(10),
          padding: EdgeInsets.zero,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
