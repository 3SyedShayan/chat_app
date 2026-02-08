import 'package:chat_app/helper/helper_function.dart';
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
      User user = (await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).user!;

      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future signOut() async {
    try {
      await HelperFunction.setUserLoggedInStatus(false);
      await HelperFunction.setUserEmail("");
      await HelperFunction.setUserName("");
      await _firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
