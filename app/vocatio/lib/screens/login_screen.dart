import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocattio/screens/home_screen.dart';
import 'package:vocattio/screens/reset_password_screen.dart';
import 'package:vocattio/screens/signup_screen.dart';
import 'package:vocattio/services/auth_service.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/dialog_exc.dart';
import 'package:vocattio/widgets/snackbars.dart';
import 'package:vocattio/widgets/text_field.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Método para validar os campos do formulário
  bool _validateForm() {
    if (emailController.text.trim().isEmpty) {
      showErrorSnackBar('Por favor, digite seu e-mail', context);
      return false;
    }
    
    if (passwordController.text.trim().isEmpty) {
      showErrorSnackBar('Por favor, digite sua senha', context);
      return false;
    }
    
    return true;
  }


  Future<void> _login() async {
    if (!_validateForm()) return; 

    setState(() {
      _isLoading = true;
    });


    try {
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      
      if (result.containsKey('error')) {
        if(mounted){
          showErrorSnackBar(result['error']['message'], context);
        }
      }else {
        final userInfo = await _authService.userLookUp(result['idToken']);
        bool isVerified = userInfo['emailVerified'];

        if(isVerified){
          if(mounted){
            showSuccessSnackBar('Login realizado com sucesso!', context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(uid: result['localId'])),
            );
          }
        }else{
          if(mounted){
            showCustomDialog(context,
            Icons.mail_outline_rounded,
            'E-mail não verificado',
            'Para usar nosso serviço, seu e-mail deve ser verificado. Ao clicar em enviar, enviaremos um e-mail para ${userInfo['email']}',
              () async {
                try {
                  await _authService.sendEmailVerification(result['idToken']);
                  if(mounted){
                    showSuccessSnackBar('E-mail de verificação enviado!', context);
                  }
                } catch (e) {
                  if(mounted){
                    showErrorSnackBar('Erro ao enviar e-mail: $e', context);
                  }
                }
              },
              'Enviar e-mail'
            );
          }
        }
      }
    } catch (e) {
      if(mounted){
        showErrorSnackBar('Erro inesperado: $e', context);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    TargetPlatform platform = theme.platform;                                                             // remover em produção
    return Scaffold(
      body: surfaceGradientContainer(
        context: context,
        child: SafeArea(
          bottom: false,
          child: platform == TargetPlatform.android || platform == TargetPlatform.iOS ? 
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsetsGeometry.directional(start: 24.0, end: 24.0, bottom: 24.0, top: 12.0),
                child: RichText(
                       text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Faça ',
                            style: textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
                          ),
                          TextSpan(
                            text: 'login\n',
                            style: textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary),
                          ),
                          TextSpan(
                            text: 'em sua\nconta!',
                            style: textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
                          )
                        ],
                        ),
                    ),
              ),
              // formulario
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenHeight = constraints.maxHeight;
                    double scale = (screenHeight / 700).clamp(1.0, 1.5);
                    double smallSpacing = (screenHeight * 0.015 * scale).clamp(6, 28);
                    double largeSpacing = (screenHeight * 0.03 * scale).clamp(12, 72);
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenHeight),
                        child: IntrinsicHeight(
                          child: primaryFormsContainer(
                            theme: theme,
                            child: Column(
                              children: [
                                SizedBox(height: largeSpacing,),
                                ..._buildLoginWidgets(
                                context: context, 
                                theme: theme, textTheme: textTheme, 
                                smallSpacing: smallSpacing, largeSpacing: largeSpacing, 
                                isMobileLayout: true
                              ),
                              ],
                            )
                          )
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          )
          : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 200, maxWidth: 400),
                      child: Image.asset('assets/images/logo_vocatio_transparente.png', fit: BoxFit.contain,)
                    ),
                    SizedBox(height: 15,),
                    Text(
                      'Faça login em sua conta',
                      style: textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                      ),
                    ),
                    SizedBox(height: 35,),
                    ..._buildLoginWidgets(
                      context: context, 
                      theme: theme, textTheme: textTheme, 
                      smallSpacing: 13, largeSpacing: 18, 
                      isMobileLayout: false
                    ),
                  ],
                ),
              ),
            ),
          )
        ),
      ),
    );
  }
  
  List<Widget> _buildLoginWidgets({
    required BuildContext context,
    required ThemeData theme,
    required TextTheme textTheme,
    required double smallSpacing,
    required double largeSpacing,
    required bool isMobileLayout,
  }){
    return [
      if(isMobileLayout) 
      Text(
        'Bem vindo de volta!',
        style: textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer
          ), 
        ),
      SizedBox(height: largeSpacing,),
      TextFieldDesign(controller: emailController, hintText: 'E-mail', context: context),
      SizedBox(height: smallSpacing,),
      TextFieldDesign(controller: passwordController, hintText: 'Senha', context: context, isPassword: true),
      SizedBox(height: smallSpacing,),
      PlatformTextButton(
        child: Text('Esqueceu sua senha?',style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, 
          decoration: TextDecoration.underline, decorationColor: theme.colorScheme.primary),
          textAlign: TextAlign.start,
        ),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPassowordScreen()));
        },
      ),
      SizedBox(height: largeSpacing,),
      primaryButtonDesign(
        context: context, 
        width: 140,
        height: 45,
        label: _isLoading ? 'Entrando...' : 'Entrar', 
        onTap: _isLoading ? () {} : () => _login(),
      ),
      SizedBox(height: smallSpacing),
        PlatformTextButton(
          onPressed: _loginWithBiometrics,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, color: theme.colorScheme.primary),
              SizedBox(width: 8),
              Text(
                'Entrar com biometria',
                style: textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      isMobileLayout ? Spacer() : SizedBox(height: largeSpacing * 2,),
      Text(
        'Não possui conta?',
        style: textTheme.bodyLarge,
      ),
      PlatformTextButton(
        child: Text('Cadastre-se',style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
        },
      ), 
    ];
  }

  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _loginWithBiometrics() async {
    try {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        showErrorSnackBar('Biometria não disponível neste dispositivo', context);
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Use sua digital ou reconhecimento facial para entrar',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Aqui você pode logar automaticamente (ex: guardar token no localStorage)
        // ou pedir o login do Firebase se o usuário já estiver salvo
        showSuccessSnackBar('Autenticado com sucesso!', context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(uid: '123')), // substitua por ID real
        );
      }
    } catch (e) {
      showErrorSnackBar('Erro na autenticação: $e', context);
    }
  }

}