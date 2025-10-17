import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocattio/extensions/string_extensions.dart';
import 'package:vocattio/screens/login_screen.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';
import 'package:vocattio/services/auth_service.dart';

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
  
  final AuthService _authService = AuthService();
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

  // Método para realizar o cadastro
  Future<void> _signUp() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        studentId: _typeSelector.contains(AccountType.aluno) 
            ? idController.text.trim() 
            : null,
      );

      _showSuccessSnackBar('Conta criada com sucesso!');
      
      // Navegar para a tela de login
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const LoginScreen())
      );
      
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                            style: textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary),
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
                          child: Container(
                            decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40)
                                  )
                                ),
                            padding: EdgeInsets.all(24.0),
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
      TextFieldDesign(controller: nameController, hintText: 'Nome', context: context),
      if (_typeSelector.contains(AccountType.aluno))
        ...[
          SizedBox(height: smallSpacing),
          TextFieldDesign(controller: idController, hintText: 'Número de identificação', context: context),
        ],
      SizedBox(height: smallSpacing),
      TextFieldDesign(controller: emailController, hintText: 'E-mail', context: context),
      SizedBox(height: smallSpacing),
      TextFieldDesign(controller: passwordController, hintText: 'Senha', context: context),
      SizedBox(height: smallSpacing),
      TextFieldDesign(controller: confirmPasswordController, hintText: 'Confirmar Senha', context: context),
      SizedBox(height: largeSpacing),
      primaryButtonDesign(
        context: context, 
        width: 140,
        height: 45,
        label: _isLoading ? 'Cadastrando...' : 'Cadastrar', 
        onTap: _isLoading ? () {} : () => _signUp(),
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