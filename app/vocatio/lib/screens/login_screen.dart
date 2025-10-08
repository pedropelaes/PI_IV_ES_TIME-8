import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocatio/screens/reset_password_screen.dart';
import 'package:vocatio/screens/signup_screen.dart';
import 'package:vocatio/widgets/button_design.dart';
import 'package:vocatio/widgets/text_field.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                    style: textTheme.headlineSmall,
                  ),
                  SizedBox(height: 35,),
                  TextFieldDesign(controller: emailController, hintText: 'E-mail', context: context),
                  SizedBox(height: 17.0,),
                  TextFieldDesign(controller: passwordController, hintText: 'Senha', context: context),
                  SizedBox(height: 13.0,),
                  PlatformTextButton(
                    child: Text('Esqueceu sua senha?',style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, 
                      decoration: TextDecoration.underline, decorationColor: theme.colorScheme.primary),
                    ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPassowordScreen()));
                    },
                  ),
                  SizedBox(height: 30,),
                  ButtonDesign(context: context, childText: 'Entrar', 
                    onPressed: (){
              
                    }
                  ),
                  SizedBox(height: 70,),
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
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
  
}