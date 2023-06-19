import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:integracao/helper/helper_function.dart';
import 'package:integracao/pages/login_page.dart';
import 'package:integracao/pages/profile_page.dart';
import 'package:integracao/pages/search_page.dart';
import 'package:integracao/service/auth_service.dart';
import 'package:integracao/service/database_service.dart';
import 'package:integracao/widgets/group_tile.dart';
import 'package:integracao/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthService authService = AuthService();
  String userName = "";
  String email = "";
  Stream? groups;
  bool _isloading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    getuserData();
  }
  getuserData() async{
    await  HelperFunctions.getUserEmail().then((value){
      setState(() {
        email = value!;
      });
    });

    await HelperFunctions.getUserName().then((value){
      userName = value!;
    });

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserGroups().then((snapshot){
      setState(() {
        groups = snapshot;
      });
    });
  }

  String getId(String res){
    return res.substring(0,res.indexOf("_"));

  }
  String getName(String res){
    return res.substring(res.indexOf("_") +1);

  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
              const SearchPage()));
            },
            child: const Icon(
                Icons.search,
            ),
          ),
          const SizedBox(width: 12,),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Grupo",style: TextStyle(
            color: Colors.white,
            fontWeight:  FontWeight.bold,
            fontSize: 27
        ),),
      ),
      drawer: Drawer(
        child: ListView(
          padding:  const EdgeInsets.symmetric(vertical: 50),
          children:  [
            const Icon(Icons.account_circle,size: 150,color: Colors.grey,),
            const SizedBox(height: 18,),
            Text(userName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: (){},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Grupo",
                style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const ProfilePage()));
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.person),
              title: const Text(
                "Perfil",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: ()async{
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        title: const Text("Sair"),
                        content: const Text("Tem certeza de que quer sair?"),
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
                            onPressed: ()async {
                              await authService.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context)=> const LoginPage()),
                                      (route) => false);
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),

                        ],
                      );
                    });
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Sair",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  popUpDialog(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return StatefulBuilder(builder: (context,setState){
            return AlertDialog(
              title: const Text(
                "Criar grupo",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isloading ? Center(
                    child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),
                  ):
                  TextFormField(
                    onChanged: (val){
                      setState((){
                        groupName = val;
                      });
                    },
                    style: TextStyle(color:  Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(20)),
                      errorBorder:OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(20)),),
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: Text("CANCELAR"),
                ),
                ElevatedButton(
                  onPressed: ()async{
                    if(groupName!=""){
                      setState((){
                        _isloading = true;
                      });
                      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).
                      createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName).whenComplete((){
                        _isloading = false;
                      });
                      Navigator.of(context).pop();
                      showSnackbar(context, Colors.green, "Grupo criado com sucesso");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: Text("CRIAR"),

                )
              ],
            );
          }) ;
        });
  }
  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.hasData){
            if(snapshot.data["groups"] != null){
              if(snapshot.data["groups"].length > 0){
                return ListView.builder(
                    itemCount: snapshot.data["groups"].length ,
                    itemBuilder: (context,index){
                      int reversIndex = snapshot.data["groups"].length - index -1;
                      return GrouTile(
                        userName: snapshot.data['fullName'],
                        groupName: getName(snapshot.data['groups'][reversIndex]),
                        groupId: getId(snapshot.data['groups'][reversIndex]),);
                    });
              }else{
                return noGroupWidget();
              }
            }else{
              return noGroupWidget();
            }
          }else{
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        });
  }
  noGroupWidget(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 12),
      child: Column(
        children: [
          //função clique
          InkWell(
            child:
            const Icon(
              Icons.add,
              size: 35,
              color: Colors.grey,
            ),onTap: (){
            popUpDialog(context);
          },),
          const SizedBox(height: 15,),
          const Text("Você não se juntou a nenhum grupo, toque no ícone adicionar para criar um grupo ou também selecione no botão de pesquisa principal para entrar no grupo existente.",
            style: TextStyle(
                fontSize:17,
                fontWeight: FontWeight.w800
            ),)
        ],
      ),
    );
  }
}
