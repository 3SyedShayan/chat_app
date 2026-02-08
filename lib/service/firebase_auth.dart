import 'package:chat_app/service/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> createUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      DatabaseService().savingUserData(name, email);
      debugPrint("User Created: ${userCredential.user.toString()}");
    } on FirebaseAuthException catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  Future loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      debugPrint(e.toString());
      SnackBar(content: Text(e.toString()));
    }
  }
}
