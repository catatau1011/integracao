import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:integracao/helper/helper_function.dart';
import 'package:integracao/pages/home_screen.dart';
import 'package:integracao/pages/login_page.dart';
import 'package:integracao/service/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  String userName = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    getUserData();
  }
  void getUserData() async {
    await HelperFunctions.getUserEmail().then((value){
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserName().then((value){
      userName = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        elevation: 0,
        title: const Text("Perfil",style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 27,
            color: Colors.white
        ),),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ) ,
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
              onTap: (){
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> const HomeScreen()));
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: (){
                Navigator.pop(context);
              },
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.person),
              title: const Text(
                "Profile",
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
                        title: const Text("Logout"),
                        content: const Text("Are you sure you wamt to lougout?"),
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
                              // ignore: use_build_context_synchronously
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
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:  CrossAxisAlignment.center,
          children: [
            Icon(Icons.account_circle,size: 120,color: Theme.of(context).primaryColor,),
            const Divider(height: 20,),
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                const Text("Nome :", style: TextStyle(fontSize: 17),),
                Text(userName, style: const TextStyle(fontSize: 17),),
              ],
            ),
            const Divider(height: 20,),
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                const Text("Email :", style: TextStyle(fontSize: 17),),
                Text(email, style: const TextStyle(fontSize: 17),),
              ],
            ),
            const Divider(height: 20,),


          ],
        ),
      ),
    );
  }

}
