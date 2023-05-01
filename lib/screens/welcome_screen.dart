import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:dbms_chat_bot/components/rounded_button.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class WelcomeScreen extends StatefulWidget {

  static const String id='welcome_screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    controller=AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    animation=ColorTween(begin: Colors.blueGrey,end: Colors.white).animate(controller);

    controller.forward();
    controller.addListener(() {
      setState(() {

      });
    });
  }

  @override
  void dispose()
  {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[
            Row(
              children: [
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 70.0,
                    child: Image.asset("images/logo.png"),
                  ),
                ),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText("Chat Bot",
                      speed:const Duration(milliseconds: 200)
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),
            RoundedButton(onPressed: (){Navigator.pushNamed(context, LoginScreen.id);},color: Colors.lightBlueAccent,label: "Log In",),
            RoundedButton(onPressed: (){Navigator.pushNamed(context, RegistrationScreen.id);},color: Colors.blueAccent,label: "Register",)
        ]
        ),
      ),
    );
  }
}




