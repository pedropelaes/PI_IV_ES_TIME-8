import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocatio/widgets/button_design.dart';
import 'package:vocatio/widgets/text_field.dart';

class SignupScreen extends StatefulWidget{
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final double _textFieldSize = 309.0;
  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
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
                    'Crie agora sua conta',
                    style: textTheme.headlineSmall,
                  ),
                  SizedBox(height: 35,),
                  TextFieldDesign(controller: emailController, hintText: 'E-mail', context: context),
                  SizedBox(height: 17.0,),
                  TextFieldDesign(controller: passwordController, hintText: 'Senha', context: context),
                  SizedBox(height: 17.0,),
                  TextFieldDesign(controller: confirmPasswordController, hintText: 'Confirmar Senha', context: context),
                  SizedBox(height: 30,),
                  ButtonDesign(context: context, childText: 'Criar', 
                    onPressed: (){
              
                    }
                  ),
                  SizedBox(height: 70,),
                  Text(
                    'Já possui conta?',
                    style: textTheme.bodyLarge,
                  ),
                  PlatformTextButton(
                      child: Text('Entrar',style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
                      onPressed: (){

                      },
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}