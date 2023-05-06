import 'package:dbms_chat_bot/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dbms_chat_bot/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'chat_screen.dart';
import 'package:image_cropper/image_cropper.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
final _storage = FirebaseStorage.instance;
late User loggedInUser;


class ScreenArguments {
  final String uid;

  ScreenArguments(this.uid);
}


class SettingsScreen extends StatefulWidget {

  static const String id = 'settings_screen';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool showSpinner = false;
  late var image = null;
  final picker = ImagePicker();
  late String newName='';
  late String imgURL='';
  late String uid;






  void pickImage() async {
    final reference = _storage.ref().child("images/${uid}");
    final i = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (i != null) {
      image = File(i.path);
      await reference.putFile(image);
      reference.getDownloadURL().then((value){
        imgURL=value;
      });
    } else {
      image = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as String;
    uid=args;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Settings'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Center(
                child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(uid).snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if(!snapshot.hasData)
                  {
                    return Container();
                  }
                final details=snapshot.data;
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            pickImage();
                          },
                          shape: CircleBorder(),
                          elevation: 0,
                          child: CircleAvatar(
                            radius: 70.0,
                            backgroundImage: details!['profile-pic'] != null
                                ? NetworkImage(details!['profile-pic'])
                                : AssetImage('assets/images/spider_pic.png')
                                    as ImageProvider,
                          ),
                        ),
                        const SizedBox(
                          height: 48.0,
                        ),
                        TextField(
                          textAlign: TextAlign.center,
                          decoration: kTextFieldDecoration.copyWith(
                              hintText: details!['name']),
                          onChanged: (value) {
                            newName = value;
                          },
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        RoundedButton(
                            label: 'Submit',
                            onPressed: () {
                              _firestore.collection('users').doc(uid).set(
                                  {
                                    'name': newName==''?details['name']:newName,
                                    'profile-pic':imgURL==''?details['profile-pic']:imgURL
                                  },SetOptions(merge: true)
                              );
                              Navigator.pushNamedAndRemoveUntil(context, ChatScreen.id, (route) => false);
                            },
                            color: Colors.blueAccent)
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
        ));
  }
}
