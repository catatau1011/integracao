

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:integracao/pages/chat_page.dart';

class GrouTile extends StatefulWidget {
final String userName;
final String groupId;
final String groupName;
const GrouTile({Key? key,required this.userName, required this.groupId,required this.groupName}) : super(key: key);

@override
State<GrouTile> createState() => _GrouTileState();
}

class _GrouTileState extends State<GrouTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
            ChatPage(
              userName: widget.userName,
              groupId: widget.groupId,
              groupName: widget.groupName,)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
        child: ListTile(
          title: Text(
            widget.groupName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Junte-se à conversa como ${widget.userName}",
            style: const TextStyle(fontSize: 13),
          ) ,
          leading: CircleAvatar(
            radius: 30,
            backgroundColor:Theme.of(context).primaryColor,
            child: Text(
              widget.groupName.substring(0,1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
