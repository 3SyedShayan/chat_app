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
      await userCollection.add({
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
}
