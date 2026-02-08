import 'package:chat_app/service/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text("Home Page"),
            ElevatedButton(onPressed: signOut, child: const Text("Sign Out")),
          ],
        ),
      ),
    );
  }

  void signOut() async {
    await FirebaseAuthService().signOut();
  }
}
