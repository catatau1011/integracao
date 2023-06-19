import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:integracao/pages/info_page.dart';
import 'package:integracao/service/database_service.dart';
import 'package:integracao/widgets/message_tile.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage({Key? key
    ,required this.userName,
    required this.groupId,
    required this.groupName}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream? chats;
  TextEditingController messageControler = TextEditingController();
  String  admin = "";

  @override
  void initState() {
    super.initState();
    getChatAndAdmin();
  }
  getChatAndAdmin(){
    DatabaseService().getChats(widget.groupId).then((val){
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((value){
      setState(() {
        admin = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed:(){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                    InfoPage(groupId: widget.groupId, groupName: widget.groupName, adminName: admin,)));
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: [
          _buildMessage(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 8),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey,
              child: Row(
                children: [
                  Expanded(
                      child:TextFormField(
                        controller: messageControler,
                        style: const TextStyle(color: Colors.white),
                        decoration:  const InputDecoration(
                          hintText: "Mensagem",
                          hintStyle:  TextStyle(color: Colors.white,fontSize: 16),
                          border: InputBorder.none,
                        ),
                      )),
                  const SizedBox(width: 12,),
                  GestureDetector(
                      onTap: (){
                        //Aqui lança a mensagem
                       senderMessage();
                      },
                      child:Container(
                        height: 50,
                        width: 50,
                        decoration:  BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),),
                      )
                  ),
                ],
              ) ,
            ),
          )
        ],
      ),
    );
  }
  _buildMessage(){
    return StreamBuilder(
        stream:chats ,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.hasData){
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context,index){
                  return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sendByMe : widget.userName ==
                          snapshot.data.docs[index]['sender']
                  );
                });
          }else{
            return Container();
          }
        });
  }

  senderMessage(){
    if(messageControler.text.isNotEmpty){
      Map<String ,dynamic> messageData ={
        "message"  : messageControler.text,
        "sender" : widget.userName,
        "time" : DateTime.now().millisecondsSinceEpoch
      };
      DatabaseService().sendMessage(widget.groupId, messageData);
      setState(() {
        messageControler.clear();
      });
    }

  }
}