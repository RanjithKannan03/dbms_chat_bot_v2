import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dbms_chat_bot/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

final _firestore=FirebaseFirestore.instance;
final _auth=FirebaseAuth.instance;
late User loggedInUser;
final picker=ImagePicker();

class ChatScreen extends StatefulWidget {

  static const String id='chat_screen';


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _controller=TextEditingController();
  late String messageText;
  late var image=null;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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

  void pickImage() async
  {
    final i=await picker.pickImage(source: ImageSource.gallery);
    if(i!=null)
      {
        setState(() {
          image=File(i.path);
        });
      }
    else
      {
        image=null;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(onPressed: (){
        _auth.signOut();
        Navigator.pushNamedAndRemoveUntil(context, WelcomeScreen.id, (route) => false);
      },
      image: image,
        imageAvailable: image!=null?true:false,
      ),
      appBar: AppBar(
        centerTitle: true,
        leading: null,
        title: const Text('Chat'),
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
                    onPressed: (){
                      _firestore.collection('messages').add({
                        "text":messageText,
                        "from":loggedInUser.email,
                        "to":"chatbot",
                        "time":Timestamp.now(),
                      }
                      );
                      _controller.clear();
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
              )
            ),
          ),
        )
      ],
    );
  }
}

class SideBar extends StatefulWidget {

  SideBar({required this.onPressed,required this.image,required this.imageAvailable});

  final Function onPressed;
  final image;
  final imageAvailable;

  @override
  State<SideBar> createState() => SideBarState();
}

class SideBarState extends State<SideBar> {


  @override
  Widget build(BuildContext context) {
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
                  backgroundImage: widget.imageAvailable?FileImage(widget.image):const AssetImage('images/spider_pic.png') as ImageProvider,
                  radius: 60.0,
                ),
                const SizedBox(
                  width: 30.0,
                ),
                const Text(
                  "Name",
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                  ),
                )
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
          )
        ],
      ),
    );
  }
}

