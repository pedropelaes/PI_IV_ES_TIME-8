import 'package:flutter/material.dart';

class PresencasScreen extends StatelessWidget {
  const PresencasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Presenças', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Turma 1',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Aluno ${index + 1}', style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: const Text('Selecione a Data', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                 color: theme.colorScheme.primary,
                 borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: 50, minWidth: double.infinity),
                  child: const Text(
                    'Reabrir Chamada',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
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
