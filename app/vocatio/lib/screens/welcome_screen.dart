import 'package:flutter/material.dart';
import 'package:vocattio/screens/login_screen.dart';
import 'package:vocattio/screens/signup_screen.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';

class WelcomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Scaffold(
      body: surfaceGradientContainer(
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
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
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
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
}