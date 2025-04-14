import 'package:flutter/material.dart';
import 'package:fyp_apps/Screen_flow/Splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
try {
  await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyBvayfwRTtOpou4ypMsUf_qeVT1-nnFs1g',
      appId: '1:652863905626:android:10b84c57f82b5c0be7dd63',
      messagingSenderId: '652863905626	',
      projectId: 'fyp-apps-53f7c',
    ),
  );
  
} catch (e) {
  print("Firebase initialization error: $e");
}
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
   const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: SplashScreen(),
     
    );
  }
}
class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( );

  }
}