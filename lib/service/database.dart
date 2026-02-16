import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection("users");
  final CollectionReference groupCollection = FirebaseFirestore.instance
      .collection("groups");

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future savingUserData(String fullname, String email) async {
    try {
      await userCollection.doc(uid).set({
        "fullname": fullname,
        "email": email,
        "groups": [],
        "uid": uid,
      });
      debugPrint("User Data Saved");
    } on FirebaseException catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  Future getUserGroups() async {
    try {
      return userCollection.doc(uid).snapshots();
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  Future createGroup(String groupName, String id, String userName) async {
    DocumentReference groupReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "groupId": "",
      "admin": "${id}_$userName",
      "members": [],
      "recentMessage": "",
      "recentMessageSender": "",
      "totalMembers": 0,
    });
    await groupReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupReference.id,
      "totalMembers": FieldValue.increment(1),
    });
    DocumentReference userDocumentReference = userCollection.doc(uid);
    await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(["${groupReference.id}_$groupName"]),
    });
  }
}
