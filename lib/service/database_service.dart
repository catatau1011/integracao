import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final String? uid;
  DatabaseService({this.uid});

  //reference for our collections
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  final CollectionReference groupCollection =
  FirebaseFirestore.instance.collection("groups");

  //Saving the userdata
  Future savingUserData(String fullName,String email) async{
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profile":"",
      "uid": uid,
    });
  }
  //getting user data
  Future gettingUserData(String email)async{
    QuerySnapshot snapshot =
    await userCollection.where("email",isEqualTo: email).get();
    return snapshot;
  }

  //get user groups
  getUserGroups() async{
    return userCollection.doc(uid).snapshots();
  }

  //create group
  Future createGroup(String userName, String id,String groupName)async{
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members":[],
      "groupId":"",
      "recentMessge":"",
      "recentMessageSender":"",
    });
    //update the members
    await groupDocumentReference.update({
      "members":FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);

    return await userDocumentReference.update({
      "groups":
      FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  //getting the chats
  getChats(String groupId)async{
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupid) async{
    DocumentReference d = groupCollection.doc(groupid);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  //store message
  sendMessage(String gtoupId,Map<String,dynamic>messageData)async{
    groupCollection.doc(gtoupId).collection("messages").add(messageData);
    groupCollection.doc(gtoupId).update({
      "recenteMessage": messageData['message'],
      "recenteMessageSender": messageData['sender'],
      "recenteMessageTime": messageData['time'].toString(),
    });
  }

//get Group members
  getGroupMembers(groupId)async{
    return groupCollection.doc(groupId).snapshots();
  }

//seach
  searchByName(String groupName){
    return groupCollection.where("groupName",isEqualTo: groupName).get();
  }

// join & exit group
  Future toggleGroup(String groupId, String userName, String groupName)async{
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);


    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];


    if(groups.contains("${groupId}_$groupName")){
      //User joined
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });

      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });

    }else{
      //user not joined
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });

      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
    }
  }

  //check is joined
  Future<bool>isUserJoined(
      String groupName, String groupId, String userName)async{
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if(groups.contains("${groupId}_$groupName")){
      return true;
    }else{
      return false;
    }
  }

}