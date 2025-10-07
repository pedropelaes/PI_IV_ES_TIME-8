import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget{
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('tela de cadastro', textAlign: TextAlign.center,),
          ],
        ),
      )
    );
  }
}