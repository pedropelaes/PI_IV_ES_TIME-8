import 'dart:io';
import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:vocattio/screens/welcome_screen.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/theme/theme.dart';
import 'package:vocattio/theme/theme_notifier.dart';
import 'package:vocattio/theme/util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  
  final themeNotifier = ThemeNotifier();
  
  setupLocator();
  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier,)
        ],
        child: DevicePreview(
          enabled: kIsWeb || !(Platform.isAndroid || Platform.isIOS),
          builder: (context) => const MainApp()
        ),
      ),
    )
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AppLifecycleListener _appLifecycleListener;

  @override
  void initState(){
    super.initState();
    _appLifecycleListener = AppLifecycleListener(
      onExitRequested: _onExitRequested
    );
  }

  Future<AppExitResponse> _onExitRequested() async {
    print("App fechando. Desconectando socket.");
    getIt<SocketService>().pedidoParaSair();

    return AppExitResponse.exit;
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, "Poppins", "Lato");
    final MaterialTheme lightScheme = MaterialTheme(textTheme);
    final MaterialTheme darkScheme = MaterialTheme(textTheme);
    final themeNotifier = Provider.of<ThemeNotifier>(context); 
    final isHighContrast = themeNotifier.isHighContrast;

    getIt<SocketService>().onConnectionLost = (){
      if(mounted){
        print("Reiniciando o app via phoenix");
        Phoenix.rebirth(context);
      }
    };

    return MaterialApp( 
      builder: DevicePreview.appBuilder,
      theme: isHighContrast ? lightScheme.lightHighContrast() : lightScheme.light(), 
      darkTheme: isHighContrast ? darkScheme.darkHighContrast() : darkScheme.dark(), 
      themeMode: themeNotifier.themeMode,
      home: WelcomeScreen()
    );
  }
}
