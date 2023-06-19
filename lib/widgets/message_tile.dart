import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sendByMe;

  const MessageTile({Key? key,
    required this.message,
    required this.sender,
    required this.sendByMe})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {

  @override
  Widget build(BuildContext context) {
    //Aqui é inicio do conteiner
    return Container(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        right: widget.sendByMe?24 : 0,
        left:  widget.sendByMe?0 : 4 ,
      ),
      alignment: widget.sendByMe ?Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sendByMe
            ? const EdgeInsets.only(left: 30)
            :const EdgeInsets.only(right: 30),
        padding:
        const EdgeInsets.only(top: 17,bottom: 17,left: 20,right: 20),

        decoration:  BoxDecoration(
          borderRadius:  widget.sendByMe ?
          const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          )
              :const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: widget.sendByMe? Theme.of(context).primaryColor: Colors.grey,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                //Aqui o nome do Usario
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing:  -0.5),
            ),
            const SizedBox(
              height: 8,
            ),
            //Aqui é o texto
            Text(widget.message,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 16,color: Colors.white))
          ],
        ),
      ),
    );
  }
}
