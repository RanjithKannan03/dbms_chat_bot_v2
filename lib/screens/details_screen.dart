import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dbms_chat_bot/components/rounded_button.dart';
import 'package:dbms_chat_bot/constants.dart';
import 'chat_screen.dart';



class DetailsScreen extends StatefulWidget {

  static const String id='details_screen';

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {

  final _firestore=FirebaseFirestore.instance;
  final _auth=FirebaseAuth.instance;
  bool showSpinner=false;
  late User loggedInUser;
  late String name;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async
  {
    try{
      final user=await _auth.currentUser;
      if(user!=null)
        {
          loggedInUser=user;
        }
    }
    catch(e)
    {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Welcome!!',
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900
                  ),
                ),
                const SizedBox(
                  height: 48.0,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  onChanged: (value){
                    name=value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your name'
                  ),
                ),
                RoundedButton(label: 'Submit',
                    onPressed: ()async{
                    _firestore.collection('users').doc(loggedInUser.uid).set(
                      {
                        'email':loggedInUser.email,
                        'name':name,
                        'profile-pic':null
                      }
                    );
                    Navigator.pushNamedAndRemoveUntil(context, ChatScreen.id, (route) => false);
                    },
                    color: Colors.blueAccent)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
