import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:integracao/pages/home_screen.dart';
import 'package:integracao/service/database_service.dart';

class InfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;

  const InfoPage({Key? key,
    required this.groupId,
    required this.groupName,
    required this.adminName})
      : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Stream? members;

  String getId(String res){
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }

  @override
  void initState() {
    super.initState();
    getMembers();
  }
  getMembers() async{
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId).then((snapshot){
      setState(() {
        members = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title:const Text("Informações do grupo"),
        actions: [
          IconButton(
              onPressed: (){
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        title: const Text("Sair do Grupo?"),
                        content: const Text("Tem certeza que deseja sair do grupo?"),
                        actions: [
                          IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: ()async{
                              DatabaseService(uid:  FirebaseAuth.instance.currentUser!.uid)
                                  .toggleGroup(widget.groupId, getName(widget.adminName), widget.groupName)
                                  .whenComplete((){
                                Navigator.pushReplacement(context , MaterialPageRoute(builder: (context)=>
                                const HomeScreen()));
                              });
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          )
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.exit_to_app,
                color: Colors.red,
              )),
        ],
      ),
      body: SingleChildScrollView(
        child:Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(0.2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                    radius: 30,
                    backgroundColor:Theme.of(context).primaryColor,
                    child: Text(
                      widget.groupName.substring(0,1).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,color: Colors.white),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Group:${widget.groupName}",
                      style: const TextStyle(fontWeight:  FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text("Admin: ${getName(widget.adminName)}")
                  ],
                )
              ],
            ),
          ),
          membersList(),
        ],
      ),
      ),
    );
  }

  membersList() {
    return StreamBuilder(
        stream: members,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.hasData){
            if(snapshot.data['members']!= null){
              if(snapshot.data['members'].length >0){
                return ListView.builder(
                    itemCount:  snapshot.data['members'].length,
                    shrinkWrap: true,
                    itemBuilder:(context, index){
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                        child: ListTile(
                            title:Text(getName(snapshot.data['members'][index])) ,
                            subtitle:Text(getId(snapshot.data['members'][index])),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                getName(snapshot.data['members'][index])
                                    .substring(0,1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                        ),
                      );
                    });
              }else{
                return const Center(
                  child: Text("NO MEMBERS"),
                );
              }
            }else{
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          }else{
            return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ));
          }
        });
  }
}