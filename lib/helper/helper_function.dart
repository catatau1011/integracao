

import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions{
  //keys
  static String userLoggedInkey = "LOGGEDINKEY";
  static String userNamekey = "USERNAMEKEY";
  static String userEmailkey = "USEREMAILKEY";

  //store data
  static Future<bool> storeUserLoginStatus(bool isLogin)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setBool(userLoggedInkey, isLogin);
  }

  static Future<bool> storeUserName(String userName)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(userNamekey, userName);
  }

  static Future<bool> storeEmail(String userEmail)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(userEmailkey, userEmail);
  }
  //read data
  static Future<bool?> getUserLoginStatus() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(userLoggedInkey);
  }

  static Future<String?> getUserName() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userNamekey);
  }

  static Future<String?> getUserEmail() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userEmailkey);
  }
}