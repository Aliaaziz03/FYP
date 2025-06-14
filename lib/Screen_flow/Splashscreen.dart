
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp_apps/Screen_flow/authentication/SignIn.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Signin()),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
  color: Colors.pink.withOpacity(0.1),
  child: Center(
    child: Image.asset(
      'assets/logo.png',
      width: 400,
      height: 400,
      fit: BoxFit.cover,
    ),
  ),
));
      

    
  }
}