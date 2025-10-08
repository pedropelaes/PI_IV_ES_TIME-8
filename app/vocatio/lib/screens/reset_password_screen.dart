import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:vocatio/widgets/button_design.dart';
import 'package:vocatio/widgets/text_field.dart';

class ResetPassowordScreen extends StatefulWidget{
  const ResetPassowordScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPassowordScreen>{
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return PlatformScaffold(
      appBar: PlatformAppBar(),
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
                      'Recupere sua senha',
                      style: textTheme.headlineSmall,
                    ),
                    SizedBox(height: 35,),
                    TextFieldDesign(controller: emailController, hintText: 'E-mail', context: context),
                    SizedBox(height: 30,),
                    ButtonDesign(context: context, childText: 'Enviar', 
                      onPressed: (){
                
                      }
                    ),
                    
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}