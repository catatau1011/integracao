import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:integracao/helper/helper_function.dart';
import 'package:integracao/pages/chat_page.dart';
import 'package:integracao/service/database_service.dart';
import 'package:integracao/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName ="";
  bool isJoined = false;
  User?user;

  String getId(String res){
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async{
    await HelperFunctions.getUserName().then((value){
      setState(() {
        userName = value!;
      });
      user = FirebaseAuth.instance.currentUser;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle:true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Pesquisar",
          style: TextStyle(
              fontSize: 27,fontWeight: FontWeight.bold,color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color:Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Pesquisar Grupo",
                          hintStyle:
                          TextStyle(color: Colors.white,fontSize: 16)),
                    )
                ),

                GestureDetector(
                  onTap: (){
                    searchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ) ,
                ),

              ],
            ),
          ),
          _isLoading ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ) : groupList(),
        ],
      ),
    );
  }
  groupList(){
    return hasUserSearched ?
    ListView.builder(
        shrinkWrap: true,
        itemCount: searchSnapshot!.docs.length,
        itemBuilder: (context,index){
          return groupTile(
            userName,
            searchSnapshot!.docs[index]['groupId'],
            searchSnapshot!.docs[index]['groupName'],
            searchSnapshot!.docs[index]['admin'],
          );
        }):
    Container();
  }

  searchMethod(){
    if(searchController.text.isNotEmpty){
      setState(() {
        _isLoading = true;
      });
      DatabaseService(uid: user!.uid).searchByName(searchController.text).then((snapshot){
        setState(() {
          searchSnapshot = snapshot;
          _isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  joinnedOrNot(
      String userName, String groupId, String groupName, String admin) async{
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value){
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile
      (String userName,String groupId,String groupName,String admin){
    joinnedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal:10,vertical:10),
      leading: CircleAvatar(
        radius:30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0,1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(groupName,style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin :${getName(admin)}"),
      trailing: InkWell(
        onTap: () async{
          await DatabaseService(uid: user!.uid).
          toggleGroup(groupId, userName, groupName);
          if(isJoined){
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Colors.green, "Entrou com sucesso no grupo");
            Future.delayed(const Duration(seconds: 2),(){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  ChatPage(userName: userName, groupId: groupId, groupName: groupName)));
            });
          }else{
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Colors.red, "Deixou o grupo $groupName");
          }
        },
        child: isJoined ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white,width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: const Text(
            "Ingressou",
            style: TextStyle(color: Colors.white),
          ),
        ):
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical:10),
          child: const Text("Entrar",
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}