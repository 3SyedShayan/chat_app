import 'package:chat_app/controller/auth_controller.dart';
import 'package:chat_app/service/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<bool> createUser(String name, String email, String password) async {
    try {
      User user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      )).user!;
      await user.updateDisplayName(name);
      await DatabaseService(uid: user.uid).savingUserData(name, email);
      debugPrint("User Created: ${user.toString()}");
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error: ${e.toString()}");
      throw e.message ?? "Registration failed";
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    }
  }

  Future logOut() async {
    try {
      await AuthController.setUserLoggedInStatus(false);
      await AuthController.setUserEmail("");
      await AuthController.setUserName("");
      await _firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }

  Future gettingUserData(String email) async {
    try {
      QuerySnapshot snapshot = await DatabaseService().userCollection
          .where("email", isEqualTo: email)
          .get();
      debugPrint(snapshot.toString());
      return snapshot;
    } catch (e) {
      return null;
    }
  }
}
