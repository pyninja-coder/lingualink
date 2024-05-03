import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lingualink/screens/login_screen.dart';
import 'package:lingualink/screens/home_screen.dart';
import 'package:lingualink/screens/user_list_screen.dart';
import 'firebase_options.dart'; // Import your Firebase options here
import 'models/settings.dart'; // Import your settings model here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Firestore persistence
    //await FirebaseFirestore.instance.settings = Settings(
     // persistenceEnabled: true,
    //);

    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Handle initialization error
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinguaLink',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthenticationWrapper(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomeScreen(),
        '/userList': (context) => UserListScreen(),
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while waiting for authentication state
        } else if (snapshot.hasData) {
          return HomeScreen(); // User is logged in, show home screen
        } else {
          return LoginPage(); // User is not logged in, show login screen
        }
      },
    );
  }
}
