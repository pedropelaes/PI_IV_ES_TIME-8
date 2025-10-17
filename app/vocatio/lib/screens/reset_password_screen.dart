import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocattio/widgets/background_containers.dart';
import 'package:vocattio/widgets/button_design.dart';
import 'package:vocattio/widgets/text_field.dart';
import 'package:vocattio/services/auth_service.dart';

class ResetPassowordScreen extends StatefulWidget{
  const ResetPassowordScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPassowordScreen>{
  final TextEditingController emailController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }

  // Método para validar o campo de e-mail
  bool _validateForm() {
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor, digite seu e-mail');
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

  // Método para enviar e-mail de reset de senha
  Future<void> _resetPassword() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.resetPassword(email: emailController.text.trim());
      
      _showSuccessSnackBar('E-mail de recuperação enviado! Verifique sua caixa de entrada.');
      
      // Voltar para a tela de login após sucesso
      Navigator.pop(context);
      
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
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text('Voltar', style: textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface),),),
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
                        text: 'Recupere ',
                        style: textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary)
                      ),
                      TextSpan(
                        text: 'a\n sua senha!',
                        style: textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface)
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
                                ..._buildResetPasswordWidgets(
                                  context: context, 
                                  theme: theme, textTheme: textTheme, 
                                  smallSpacing: smallSpacing, largeSpacing: largeSpacing, 
                                  isMobileLayout: true
                                )
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
          ) : 
            Padding(
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
                          'Recupere sua senha',
                          style: textTheme.headlineSmall,
                        ),
                        ..._buildResetPasswordWidgets(
                          context: context, 
                          theme: theme, textTheme: textTheme, 
                          smallSpacing: 13.0, largeSpacing: 30, 
                          isMobileLayout: false
                        )
                      ],
                    ),
                  ),
                ),
          )
        ),
      ),
    );
  }

  List<Widget> _buildResetPasswordWidgets({
    required BuildContext context,
    required ThemeData theme,
    required TextTheme textTheme,
    required double smallSpacing,
    required double largeSpacing,
    required bool isMobileLayout,
  }){
    return [
      SizedBox(height: largeSpacing,),
      Text(
        'Insira o e-mail relacionado a sua conta.\n Você recebera um link para recuperar sua senha,',
        style: textTheme.headlineSmall?.copyWith(
          color: isMobileLayout ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: largeSpacing,),
      TextFieldDesign(controller: emailController, hintText: 'E-mail', context: context),
      SizedBox(height: largeSpacing,),
      primaryButtonDesign(
        context: context, 
        width: 140,
        height: 45,
        label: _isLoading ? 'Enviando...' : 'Enviar', 
        onTap: _isLoading ? () {} : () => _resetPassword(),
      ),
    ];
  }
}