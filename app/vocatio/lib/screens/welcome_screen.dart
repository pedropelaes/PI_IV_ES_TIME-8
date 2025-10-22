import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocattio/screens/login_screen.dart';
import 'package:vocattio/screens/scan_qrcode.dart';
import 'package:vocattio/screens/signup_screen.dart';
import 'package:vocattio/screens/via_code.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:audioplayers/audioplayers.dart';

class WelcomeScreen extends StatefulWidget{
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final SocketService _socketService = getIt<SocketService>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isConnecting = true;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _initConnection() async{
    try{
      await _socketService.connect();
      print('Conexao estabelecida');
    }catch(e){
      if (mounted) {
        _showErrorSnackBar('Não foi possivel estabelecer uma conexão ao servidor. Por favor, reinicie o app');
      }
    } finally{
      if(mounted){
        setState(() {
          _isConnecting = false;
        });
      }
    }

  }

  Future<void> _audioAbertura() async {
    try {
      await _audioPlayer.play(AssetSource('audios/VocattioAudio.mp3'));
    } catch (e) {
      debugPrint('Erro ao tocar áudio: $e');
    }
  }

  @override
  void initState(){
    super.initState();
    _initConnection();
    if(!kIsWeb)_audioAbertura();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Scaffold(
      body: Stack(
        children: [
          surfaceGradientContainer(
            horizontal: false,
            context: context,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenHeight = constraints.maxHeight;
                    double scale = (screenHeight / 700).clamp(1.0, 1.5);
                    double smallSpacing = (screenHeight * 0.015 * scale).clamp(6, 28);
                    double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 400),
                              child: Image.asset(
                                'assets/images/logo_vocatio_transparente.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: largeSpacing), // Usando valor fixo para simplicidade
                            Text(
                              'Bem vindo!',
                              textAlign: TextAlign.center, // Garante que o texto fique centralizado
                              style: textTheme.displaySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: largeSpacing),
                            bigTransparentButtonDesign(
                              context: context, 
                              label: 'Entrar',
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                              }
                            ),
                            SizedBox(height: smallSpacing,),
                            primaryButtonDesign(
                              context: context, 
                              width: 255.0,
                              height: 55.0,
                              label: 'Cadastrar', 
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                              }
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if(_isConnecting)
            surfaceGradientContainer(context: context, horizontal: false,
            child: Center(
              child: CircularProgressIndicator(color: theme.colorScheme.onPrimaryContainer,),
            ))
          
        ]
      ),
    );
  }
}