import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocatio/screens/signUp_screen.dart';
import 'package:vocatio/theme/theme.dart';
import 'package:vocatio/theme/theme_notifier.dart';
import 'package:vocatio/theme/util.dart';

void main() {
  final themeNotifier = ThemeNotifier();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier,)
      ],
      child: DevicePreview(
      enabled: true,                                                                // desabilitar para builds distribuiveis
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

    return MaterialApp(
      builder: DevicePreview.appBuilder,
      theme: isHighContrast ? lightScheme.lightHighContrast() : lightScheme.light(), 
      darkTheme: isHighContrast ? darkScheme.darkHighContrast() : darkScheme.dark(), 
      themeMode: themeNotifier.themeMode, 
      home: SignupScreen()
    );
  }
}
