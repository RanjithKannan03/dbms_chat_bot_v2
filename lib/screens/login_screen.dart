import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dbms_chat_bot/components/rounded_button.dart';
import 'package:dbms_chat_bot/constants.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {

  static const String id='login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _auth=FirebaseAuth.instance;
  bool showSpinner=false;
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  const SizedBox(
                    height: 48.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value){
                      email=value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: "Enter your email"
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    onChanged: (value){
                      password=value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: "Enter your password"
                    ),
                  ),
                  RoundedButton(label: 'Log In',
                      onPressed: () async {
                    setState(() {
                      showSpinner=true;
                    });
                    try{
                      final user=await _auth.signInWithEmailAndPassword(email: email, password: password);
                      if(user!=null)
                      {
                        Navigator.pushNamedAndRemoveUntil(context, ChatScreen.id, (route) => false);
                      }
                      setState(() {
                        showSpinner=false;
                      });
                    }
                    catch(e)
                      {
                        print(e);
                      }
                    },
                      color: Colors.lightBlueAccent)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
