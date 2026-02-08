import 'package:chat_app/helper/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/shared/constants.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: Constants.apiKey,
        authDomain: Constants.authDomain,
        projectId: Constants.projectId,
        storageBucket: Constants.storageBucket,
        messagingSenderId: Constants.messagingSenderId,
        appId: Constants.appId,
        measurementId: Constants.measurementId,
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp( MainApp());
}

class MainApp extends StatefulWidget {
  bool _isSignedIn = false; 
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  getUserLoggedInStatus();
  }


  getUserLoggedInStatus() async {
    await HelperFunction.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          widget._isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
