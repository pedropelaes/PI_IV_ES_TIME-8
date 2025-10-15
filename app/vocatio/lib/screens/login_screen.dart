import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocattio/screens/reset_password_screen.dart';
import 'package:vocattio/screens/signup_screen.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
          child:  Platform.isAndroid || Platform.isIOS || platform == TargetPlatform.android || platform == TargetPlatform.iOS ? 
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
      TextFieldDesign(controller: passwordController, hintText: 'Senha', context: context),
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
      ButtonDesign(context: context, childText: 'Entrar', 
        onPressed: (){
  
        }
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
}