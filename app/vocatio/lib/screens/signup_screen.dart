import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocatio/screens/login_screen.dart';
import 'package:vocatio/teste_servidor.dart';
import 'package:vocatio/widgets/button_design.dart';
import 'package:vocatio/widgets/text_field.dart';

class SignupScreen extends StatefulWidget{
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

enum AccountType { aluno, professor}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Set<AccountType> _typeSelector = {AccountType.aluno};

  @override
  Widget build(BuildContext context){
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    String PouA = _typeSelector.contains(AccountType.aluno)?'aluno!' : 'professor!';
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
                    'Crie agora sua conta, $PouA',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  SizedBox(height: 13,),
                  SegmentedButton(
                    segments: [
                      ButtonSegment(
                        value: AccountType.aluno,
                        icon: Icon(Icons.school_outlined),
                        tooltip: 'Aluno'
                      ),
                      ButtonSegment(
                        value: AccountType.professor,
                        icon: Icon(Icons.co_present_outlined),
                        tooltip: 'Professor'
                      ),
                    ], 
                    selected: _typeSelector,
                    onSelectionChanged: (Set<AccountType> newSelection){
                      setState(() {
                        _typeSelector = newSelection;
                      });
                    },
                    multiSelectionEnabled: false,
                    emptySelectionAllowed: false,
                  ),
                  SizedBox(height: 13,),
                  TextFieldDesign(controller: nameController, hintText: 'Nome', context: context),
                  if (_typeSelector.contains(AccountType.aluno))
                    ...[
                      SizedBox(height: 13,),
                      TextFieldDesign(controller: idController, hintText: 'Número de identificação', context: context),
                    ],
                  SizedBox(height: 17,),
                  TextFieldDesign(controller: emailController, hintText: 'E-mail', context: context),
                  SizedBox(height: 17.0,),
                  TextFieldDesign(controller: passwordController, hintText: 'Senha', context: context),
                  SizedBox(height: 17.0,),
                  TextFieldDesign(controller: confirmPasswordController, hintText: 'Confirmar Senha', context: context),
                  SizedBox(height: 30,),
                  ButtonDesign(context: context, childText: 'Criar', 
                    onPressed: (){
                      conectar();
                    }
                  ),
                  SizedBox(height: 60,),
                  Text(
                    'Já possui conta?',
                    style: textTheme.bodyLarge,
                  ),
                  PlatformTextButton(
                      child: Text('Entrar',style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
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