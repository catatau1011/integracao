import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:integracao/firebase_options.dart';
import 'package:integracao/pages/home_screen.dart';
import 'package:integracao/pages/login_page.dart';
import 'helper/helper_function.dart';
import 'package:flutter/foundation.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;
  @override
  void initState() {
    super.initState();
    getUserLoginStatus();
  }
  getUserLoginStatus() async{
    await HelperFunctions.getUserLoginStatus().then((value){
      if(value!= null){
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _isSignedIn ? const HomeScreen():const LoginPage(),
    );
  }

}
