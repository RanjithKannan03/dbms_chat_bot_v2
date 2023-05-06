import 'package:dbms_chat_bot/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dbms_chat_bot/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


final _firestore=FirebaseFirestore.instance;
final _auth=FirebaseAuth.instance;
late User loggedInUser;
late DialogFlowtter agent;




class ChatScreen extends StatefulWidget {

  static const String id='chat_screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  final _controller=TextEditingController();
  late String messageText;
  bool showSpinner=false;
  double opacity=1;

  @override
  void initState(){
    super.initState();
    getCurrentUser();
    // Future.delayed(Duration.zero,()async{
    //   try{
    //     await _firestore.collection('users').doc(loggedInUser.uid).get().then((value){
    //       details=value.data();
    //     });
    //   }
    //   catch(e)
    //   {
    //     print(e);
    //   }
    // });
    createDialogflowtterAgent();
  }

  void getCurrentUser()async{
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


  void createDialogflowtterAgent()async{
    try{
      final DialogAuthCredentials credentials=await DialogAuthCredentials.fromFile('assets/dialog_flow_auth.json');
      DialogFlowtter instance=DialogFlowtter(credentials: credentials);
      if(instance!=null)
        {
          agent=instance;
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
      drawer: SideBar(onPressed: (){
        _auth.signOut();
        Navigator.pushNamedAndRemoveUntil(context, WelcomeScreen.id, (route) => false);
      },
      ),
      appBar: AppBar(
        centerTitle: true,
        leading: null,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height*0.1),
          child: Row(
            children: [
              Container(
                height: 45.0,
                child: ModalProgressHUD(
                  inAsyncCall: showSpinner,
                    color: null,
                    child: Image.asset(
                        'assets/images/logo.png',
                    opacity: AnimationController(
                      vsync: this,
                      value: opacity
                    ),)
                ),
              ),
              Text('Chat')
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (value){
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                    color: Colors.lightBlueAccent,
                    ),
                    onPressed: () async {
                      _firestore.collection('messages').add({
                        "text":messageText,
                        "from":loggedInUser.email,
                        "to":"chatbot",
                        "time":Timestamp.now(),
                      }
                      );
                      _controller.clear();
                      setState(() {
                        showSpinner=true;
                        opacity=0;
                      });
                      FocusNode currentFocus=FocusScope.of(context);
                      if(!currentFocus.hasPrimaryFocus)
                        {
                          currentFocus.unfocus();
                        }
                      QueryInput query=QueryInput(
                        text: TextInput(
                          text: messageText,
                          languageCode: 'en'
                        )
                      );
                      DetectIntentResponse response=await agent.detectIntent(queryInput: query);
                      String? textResponse=response.text;
                      _firestore.collection('messages').add(
                        {
                          "text":textResponse,
                          "from":"chatbot",
                          "to":loggedInUser.email,
                          "time":Timestamp.now()
                        }
                      );
                      setState(() {
                        showSpinner=false;
                        opacity=1;
                      });
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


class MessageStream extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').orderBy('time').snapshots(),
        builder: (context,AsyncSnapshot snapshot){
          if(!snapshot.hasData)
            {
              return Container();
            }
          final messages=snapshot.data.docs.reversed;
          List<MessageBubble> messageBubbles=[];
          for(var message in messages)
            {
              if(message['from']==loggedInUser.email||message['to']==loggedInUser.email)
                {
                  final messageText=message['text'];
                  final isMe=message['from']==loggedInUser.email?true:false;
                  final messageBubble=MessageBubble(messageText: messageText, isMe: isMe);
                  messageBubbles.add(messageBubble);
                }
            }
          return Expanded(
            child: ListView(
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
              children: messageBubbles,
            ),
          );
        }
    );
  }
}



class MessageBubble extends StatelessWidget {
  MessageBubble({required this.messageText,required this.isMe});

  final String messageText;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Material(
            elevation: 5.0,
            borderRadius: isMe?const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0)
            ):const BorderRadius.only(
              topRight: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0)
            ),
            color: isMe?Colors.lightBlue:Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              child: Text(
                messageText,
                style: TextStyle(
                  color: isMe?Colors.white:Colors.blue,
                ),
              )
            ),
          ),
        )
      ],
    );
  }
}

class SideBar extends StatefulWidget {

  SideBar({required this.onPressed});

  final Function onPressed;

  @override
  State<SideBar> createState() => SideBarState();
}

class SideBarState extends State<SideBar> {



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(loggedInUser.uid).snapshots(),
      builder: (context,AsyncSnapshot snapshot){
          if(!snapshot.hasData)
            {
              return Container();
            }
          final details=snapshot.data;
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: details!['profile-pic']!=null?NetworkImage(details!['profile-pic']):const AssetImage('assets/images/spider_pic.png') as ImageProvider,
                        radius: 60.0,
                      ),
                      const SizedBox(
                        width: 30.0,
                      ),
                      Text(
                        details!['name'],
                        style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ),
                ListTile(
                  onTap: (){
                    Navigator.pushNamed(context, SettingsScreen.id,arguments: '${loggedInUser.uid}');
                  },
                  title: Row(
                    children: const [
                      Icon(Icons.settings),
                      Text('Settings')
                    ],
                  ),
                ),
                ListTile(
                  onTap: (){
                    widget.onPressed();
                  },
                  title:Row(
                    children: const [
                      Icon(Icons.logout),
                      Text('Logout')
                    ],
                  ),
                ),
              ],
            ),
          );
      },

    );
  }
}

