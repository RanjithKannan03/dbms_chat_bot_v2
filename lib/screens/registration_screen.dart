import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dbms_chat_bot/components/rounded_button.dart';
import 'package:dbms_chat_bot/constants.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'details_screen.dart';

class RegistrationScreen extends StatefulWidget {

  static const String id='registration_page';

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

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
                  RoundedButton(label: 'Register',
                      onPressed: ()async{
                    try{
                      setState(() {
                        showSpinner=true;
                      });
                      final newUser=await _auth.createUserWithEmailAndPassword(email: email, password: password);
                      if(newUser!=null)
                        {
                          Navigator.pushNamedAndRemoveUntil(context, DetailsScreen.id, (route) => false);
                          setState(() {
                            showSpinner=false;
                          });
                        }
                    }
                    catch(e)
                        {
                          print(e);
                        }
                      },
                      color: Colors.blueAccent)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
