import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocattio/extensions/string_extensions.dart';
import 'package:vocattio/models/user.dart';
import 'package:vocattio/screens/login_screen.dart';
import 'package:vocattio/services/auth_service.dart';
import 'package:vocattio/services/locator.dart';
import 'package:vocattio/services/socket/socket_service.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';

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
  final _authService = AuthService();
  final SocketService _socketService = getIt<SocketService>();
  
  
  bool _isLoading = false;
  
  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    idController.dispose();
    super.dispose();
  }

  Set<AccountType> _typeSelector = {AccountType.aluno};

  // Método para validar os campos do formulário
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor, digite seu nome');
      return false;
    }
    
    if (_typeSelector.contains(AccountType.aluno) && idController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor, digite seu número de identificação');
      return false;
    }
    
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor, digite seu e-mail');
      return false;
    }
    
    if (passwordController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor, digite sua senha');
      return false;
    }
    
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorSnackBar('As senhas não coincidem');
      return false;
    }
    
    if (passwordController.text.length < 6) {
      _showErrorSnackBar('A senha deve ter pelo menos 6 caracteres');
      return false;
    }
    
    return true;
  }

  // Método para mostrar mensagens de erro
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Método para mostrar mensagens de sucesso
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  Future<void> _signup() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authResult = await _authService.signup(    // criando usuario no firebase auth
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (authResult.containsKey('error')) {
        _showErrorSnackBar(authResult['error']['message']);
        return;                                               
      }

      final registerNewUserResult = await _registerNewUser(     // registrando usuario no banco
        User(
          uid: authResult['localId'],
          nome: nameController.text,
          email: emailController.text.trim(),
          tipo: _typeSelector.first.name,
          codigo: idController.text.trim(),
        ),
      );

      if (registerNewUserResult != true) {
        final errorMessage = registerNewUserResult == false
            ? 'Servidor não pôde registrar o usuário'
            : 'Erro ao adquirir resposta do servidor';
        _showErrorSnackBar(errorMessage);
        await _authService.deleteUser(authResult['idToken']);
        return; 
      }

      final verificationEmailResult =                                       // enviando e-mail de verificacao
          await _authService.sendEmailVerification(authResult['idToken']);

      if (verificationEmailResult.containsKey('error')) {
        _showErrorSnackBar(verificationEmailResult['error']['message']);
        return; 
      }

      _showSuccessSnackBar('Cadastro realizado com sucesso! Verifique seu e-mail.');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Erro inesperado: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool?> _registerNewUser(User newUser) async {
    Map<String, dynamic> jsonCadastro = {
      "operacao": "Cadastro",
      ...newUser.toJson()
    };

    try {
      _socketService.send(jsonCadastro);

      final responseData = await _socketService.messages.firstWhere(
        (data) {
          try {
            final message = jsonDecode(data is String ? data : utf8.decode(data));
            return message['operacao'] == 'ResultadoCadastro';
          } catch (e) {
            return false;
          }
        },
      ).timeout(const Duration(seconds: 10)); 

      final responseJson = jsonDecode(responseData is String ? responseData : utf8.decode(responseData));
      
      final resultado = responseJson['resultado'];

      print("Resposta de cadastro recebida: $resultado");

      if (resultado == 'true' || resultado == true) { 
        return true;
      } else {
        return false;
      }

    } on TimeoutException {
      print("Erro: Tempo de resposta para o cadastro esgotado.");
      return null;
    } catch (e) {
      print("Erro ao processar resposta do cadastro: $e");
      return null; 
    }
  }


  @override
  Widget build(BuildContext context){
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    TargetPlatform platform = theme.platform;                                                             // remover em produção
    String PouA = (_typeSelector.contains(AccountType.aluno)?'aluno!' : 'professor!').capitalize();
    return Scaffold(
      body: surfaceGradientContainer(
        context: context,
        child: SafeArea(
          bottom: false,
          child: platform == TargetPlatform.android || platform == TargetPlatform.iOS ? 
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // regiao superior
              Padding(
                padding: EdgeInsetsGeometry.directional(start: 24.0, end: 24.0, bottom: 24.0, top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                       text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Crie agora\nsua conta,\n',
                            style: textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface),
                          ),
                          TextSpan(
                            text: PouA,
                            style: textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800
                            ),
                          )
                        ],
                          
                        ),
                      
                    ),
                    ],
                ),
              ),
              // regiao inferior
        
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
                                ..._buildFormWidgets(
                                  context: context, 
                                  theme: theme, textTheme: textTheme, 
                                  smallSpacing: smallSpacing, largeSpacing: largeSpacing, 
                                  isMobileLayout: true
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },

                ),
              ),
            ],
          ) : Padding(
            padding: EdgeInsetsGeometry.all(24.0),
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
                  ..._buildFormWidgets(
                    context: context, 
                    theme: theme, textTheme: textTheme, 
                    smallSpacing: 13.0, largeSpacing: 18.0, 
                    isMobileLayout: false
                  )
                ],
              ),
            ),
          ),
          )
        ) ,
      )
    );
  }
  List<Widget> _buildFormWidgets({   // construcao dos widgets do formulario
    required BuildContext context,
    required ThemeData theme,
    required TextTheme textTheme,
    required double smallSpacing,
    required double largeSpacing,
    required bool isMobileLayout,
  }) {
    return [
      SegmentedButton(
        segments: const [
          ButtonSegment(
            value: AccountType.aluno,
            icon: Icon(Icons.school_outlined),
            tooltip: 'Aluno',
          ),
          ButtonSegment(
            value: AccountType.professor,
            icon: Icon(Icons.co_present_outlined,),
            tooltip: 'Professor',
          ),
        ],
        selected: _typeSelector,
        onSelectionChanged: (Set<AccountType> newSelection) {
          setState(() {
            _typeSelector = newSelection;
          });
        },
        multiSelectionEnabled: false,
        emptySelectionAllowed: false,
      ),
      SizedBox(height: largeSpacing),
      TextFieldDesign(controller: nameController, hintText: 'Nome *', context: context),
      //if (_typeSelector.contains(AccountType.aluno))
      SizedBox(height: smallSpacing),
      TextFieldDesign(controller: idController, hintText: _typeSelector.contains(AccountType.aluno) ? 'Mátricula do aluno *' : 'ID do professor *', 
      context: context),
      SizedBox(height: smallSpacing),
      TextFieldDesign(controller: emailController, hintText: 'E-mail *', context: context),
      SizedBox(height: smallSpacing),
      TextFieldDesign(controller: passwordController, hintText: 'Senha *', context: context, isPassword: true),
      SizedBox(height: smallSpacing),
      TextFieldDesign(controller: confirmPasswordController, hintText: 'Confirmar Senha *', context: context, isPassword: true),
      SizedBox(height: smallSpacing,),
      Text(
        _typeSelector.contains(AccountType.aluno) ? 'Você está se registrando como aluno.' : 'Você está se registrando como professor.',
        style: textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary
        ),
      ),
      SizedBox(height: largeSpacing),
      primaryButtonDesign(
        context: context, 
        width: 140,
        height: 45,
        label: _isLoading ? 'Cadastrando...' : 'Cadastrar', 
        onTap: _isLoading ? () {} : () => _signup(),
      ),
      isMobileLayout ? const Spacer() : const SizedBox(height: 60),
      Text(
        'Já possui conta?',
        style: textTheme.bodyLarge,
      ),
      PlatformTextButton(
        child: Text('Entrar', style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
      )
    ];
  }
}