import 'dart:io';
import 'dart:ui';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vocattio/screens/welcome_screen.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/theme/theme.dart';
import 'package:vocattio/theme/theme_notifier.dart';
import 'package:vocattio/theme/util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocattio/widgets/dialog_exc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('selected_theme') ?? 'system';

  final themeNotifier = ThemeNotifier();

  switch (savedTheme) {
    case "light":
      themeNotifier.setTheme(ThemeMode.light);
      break;
    case "dark":
      themeNotifier.setTheme(ThemeMode.dark);
      break;
    default:
      themeNotifier.setTheme(ThemeMode.system);
  }

  setupLocator();

  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  runApp(
    Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier)
        ],
        child: DevicePreview(
          enabled: kIsWeb || !(Platform.isAndroid || Platform.isIOS),
          builder: (context) => const MainApp(),
        ),
      ),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AppLifecycleListener _appLifecycleListener;
  bool _connDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _appLifecycleListener = AppLifecycleListener(onExitRequested: _onExitRequested);

    getIt<SocketService>().onConnectionLost = () async {
      int attempts = 0;
      const int maxAttempts = 3;
      while(attempts < maxAttempts && !getIt<SocketService>().isConnected){
        attempts++;
        try{
          await getIt<SocketService>().connect();
          print('Reconectado após perda de conexão (tentativa $attempts).');
          return;
        }catch(e){
          print("Falha ao reconectar (tentativa :$attempts): $e");
          await Future.delayed(Duration(seconds: 2 * attempts));
        }
      }

      final ctx = navigatorKey.currentState?.overlay?.context ?? navigatorKey.currentState?.context;
      if(ctx == null) return;
      if(_connDialogShowing) return;
      showCustomDialog(
        ctx, 
        Icons.wifi_tethering_error_outlined,
        'Conexão perdida', 
        'Não foi possível reconectar ao servidor. Tente novamente mais tarde.', 
        (){
          final nav = navigatorKey.currentState;
          if (nav == null) return;
          try {
            nav.pop();
          } catch (e) {
            print('Erro ao fechar dialog: $e');
          }

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            
        }, 
        'Ok'
      ).then((_) => _connDialogShowing = false);
    };

    WidgetsBinding.instance.addPostFrameCallback((_){
      getIt<SocketService>().connect().catchError((_){
        // onConnectionLost cuida do dialog e retrys
      });
    });
  }

  Future<AppExitResponse> _onExitRequested() async {
    print("App fechando. Desconectando socket.");
    getIt<SocketService>().pedidoParaSair();
    return AppExitResponse.exit;
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    getIt<SocketService>().onConnectionLost = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, "Poppins", "Lato");
    final MaterialTheme lightScheme = MaterialTheme(textTheme);
    final MaterialTheme darkScheme = MaterialTheme(textTheme);

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isHighContrast = themeNotifier.isHighContrast;

    return MaterialApp(
      builder: DevicePreview.appBuilder,
      navigatorKey: navigatorKey,
      theme: isHighContrast ? lightScheme.lightHighContrast() : lightScheme.light(),
      darkTheme: isHighContrast ? darkScheme.darkHighContrast() : darkScheme.dark(),
      themeMode: themeNotifier.themeMode,
      home: WelcomeScreen(),
    );
  }
}
