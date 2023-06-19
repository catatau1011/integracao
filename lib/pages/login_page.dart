import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:integracao/helper/helper_function.dart';
import 'package:integracao/pages/home_screen.dart';
import 'package:integracao/pages/register_page.dart';
import 'package:integracao/service/auth_service.dart';
import 'package:integracao/service/database_service.dart';
import 'package:integracao/widgets/widgets.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey= GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading ? Center(child: CircularProgressIndicator(color:Theme.of(context).primaryColor,),):
      SingleChildScrollView(
        child:  Padding(
          padding: const EdgeInsets.symmetric(vertical: 80,horizontal: 20),
          child: Form(
              key: formKey,
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:CrossAxisAlignment.center,
                children: [
                  const Center(
                    child:Text("Grupo de Conversa",
                      style:
                      TextStyle(fontSize: 38,fontWeight: FontWeight.w900 ),),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Center(
                    child:Text("Entre agora para ver o que seus amigos estão falando ",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 20,fontWeight: FontWeight.w400 ),),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Image.asset("assets/images/login.png",height: 200,),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    onChanged: (val){
                      setState(() {
                        email = val;
                      });
                    },
                    validator: (val){
                      return RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val!)
                          ? null
                          :"por favor digite um email válido";

                    },
                    decoration:  InputDecoration(
                        enabledBorder:  const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor,width: 1.0),
                        ),
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        hintText: "Por favor , insira seu email."
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    onChanged: (val){
                      setState(() {
                        password = val;
                      });
                    },
                    validator: (val){
                      if(val!.length<6){
                        return "A senha deve ter pelo menos 6 caracteres";
                      }else{
                        return null;
                      }
                    },
                    obscureText: true,
                    decoration:  InputDecoration(
                        enabledBorder:  const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor,width: 1.0),
                        ),
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
                        labelText: "Senha",
                        prefixIcon: const Icon(Icons.lock),
                        hintText: "Por favor , insira sua senha."
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                          )
                      ),
                      onPressed: () {
                        logIn();
                      },
                      child: const Center(
                        child: Text("Login",style: TextStyle(
                            fontSize: 18
                        ),),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Text.rich(TextSpan(
                      text: "Não tem uma conta?",
                      style: const TextStyle(fontSize: 14,color: Colors.black),
                      children: [
                        TextSpan(
                            text: "Registre-se aqui",
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                                decoration:TextDecoration.underline ),
                            recognizer:TapGestureRecognizer()..onTap=(){
                              //Move to register
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const RegisterPage()));
                            }
                        )
                      ]
                  ))
                ],
              )),),
      ),
    );
  }
  void logIn() async{
    if(formKey.currentState!.validate()){
      setState(() {
        _isLoading=true;
      });
      await  authService.loginWithEmailAndPassword(email, password).then((value) async{
        if(value == true){
          QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);
          await HelperFunctions.storeUserLoginStatus(true);
          await HelperFunctions.storeEmail(email);
          await HelperFunctions.storeUserName(snapshot.docs[0]["fullName"]);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
        }else{
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
