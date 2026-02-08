import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class DatabaseService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future savingUserData(String fullname, String email) async {
    try {
      await firestore.collection("users").add({
        "fullname": fullname,
        "email": email,
      });
      debugPrint("User Data Saved");
    } on FirebaseException catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }
}
