import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_apps/Screen_flow/HomeScreen.dart';
import 'package:fyp_apps/Screen_flow/Splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp_apps/Screen_flow/authentication/SignUp.dart';
import 'auth.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {

  String? errorMessage = '';
  bool isLogin = true;
  String? savedEmail = ''; // Variable to store the last used email

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLastUsedEmail();  // Load the last used email when the page is created
  }

  // Load the last used email from shared preferences
  Future<void> _loadLastUsedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedEmail = prefs.getString('lastUsedEmail') ?? '';  // Default to empty if not found
      _controllerEmail.text = savedEmail ?? '';  // Set the email in the text field
    });
  }

  /// Email & Password Login
  Future<void> signInWithEmailAndPassword() async {
    if (_controllerEmail.text.isEmpty || !_controllerEmail.text.contains('@')) {
      setState(() {
        errorMessage = "Please enter a valid email.";
      });
      return;
    }

    if (_controllerPassword.text.isEmpty || _controllerPassword.text.length < 6) {
      setState(() {
        errorMessage = "Password must be at least 6 characters.";
      });
      return;
    }

    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // Store the email for future use
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('lastUsedEmail', _controllerEmail.text);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          errorMessage = "No user found for this email. Please register first.";
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          errorMessage = "Incorrect password. Please try again.";
        });
      } else {
        setState(() {
          errorMessage = e.message ?? "An unknown error occurred.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred. Please try again.";
      });
    }
  }

 /* /// Biometric Authentication
  Future<void> _authenticateWithFingerprint() async {
    try {
      bool isBiometricAvailable = await _localAuth.canCheckBiometrics;
      if (!isBiometricAvailable) {
        setState(() {
          errorMessage = "Fingerprint authentication is not available.";
        });
        return;
      }

      bool isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Use your fingerprint to authenticate',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (isAuthenticated) {
        // Navigate to the desired screen after successful authentication
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PeriodSelectionScreen()),
        );
      } else {
        setState(() {
          errorMessage = "Fingerprint authentication failed.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error during authentication: $e";
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView( // Wrap with SingleChildScrollView to prevent overflow
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // Adjust width
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Shrinks to fit content
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'LOGIN',
                    style: GoogleFonts.patrickHand(
                      fontSize: 40,
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Form(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _controllerEmail, // Email field
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.patrickHand(),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.patrickHand(),
                              hintText: 'Enter email',
                              hintStyle: GoogleFonts.patrickHand(),
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _controllerPassword, // Password field
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            style: GoogleFonts.patrickHand(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.patrickHand(),
                              hintText: 'Enter password',
                              hintStyle: GoogleFonts.patrickHand(),
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (errorMessage != null && errorMessage!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color.fromARGB(255, 175, 69, 105), Color.fromARGB(255, 228, 157, 181)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: MaterialButton(
                                      onPressed: signInWithEmailAndPassword,
                                      textColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                /*IconButton(
                                  icon: const Icon(Icons.fingerprint, size: 40, color: Colors.pink),
                                  onPressed: _authenticateWithFingerprint,
                                ),*/
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignUp()),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.patrickHand(
                                fontSize: 16,
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.pink,
                                decorationThickness: 2
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
