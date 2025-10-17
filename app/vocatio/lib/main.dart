import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vocattio/firebase_options.dart';

import 'package:vocattio/screens/signup_screen.dart';
import 'package:vocattio/screens/welcome_screen.dart';
import 'package:vocattio/theme/theme.dart';
import 'package:vocattio/theme/theme_notifier.dart';
import 'package:vocattio/theme/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase com configurações específicas
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso');
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
  }
  
  final themeNotifier = ThemeNotifier();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier,)
      ],
      child: DevicePreview(
        enabled: true,
        builder: (context) => const MainApp()
      ),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, "Poppins", "Lato");
    final MaterialTheme lightScheme = MaterialTheme(textTheme);
    final MaterialTheme darkScheme = MaterialTheme(textTheme);
    final themeNotifier = Provider.of<ThemeNotifier>(context); 
    final isHighContrast = themeNotifier.isHighContrast;

    return MaterialApp( // provavelmente sera preciso trocar para PlatformApp na build final
      builder: DevicePreview.appBuilder,
      theme: isHighContrast ? lightScheme.lightHighContrast() : lightScheme.light(), 
      darkTheme: isHighContrast ? darkScheme.darkHighContrast() : darkScheme.dark(), 
      themeMode: themeNotifier.themeMode,
      home: WelcomeScreen()
    );
  }
}
