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
    _loadLastUsedEmail();
  }

  Future<void> _loadLastUsedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedEmail = prefs.getString('lastUsedEmail') ?? '';
      _controllerEmail.text = savedEmail ?? '';
    });
  }

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

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('lastUsedEmail', _controllerEmail.text);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = "No user found for this email. Please register first.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Incorrect password. Please try again.";
        } else {
          errorMessage = e.message ?? "An unknown error occurred.";
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      color: Colors.pink.withOpacity(0.1),
      child:SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign In',
                  style: GoogleFonts.patrickHand(
                    fontSize: 40,
                    color:  Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  
                  width: MediaQuery.of(context).size.width * 0.9,
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
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                       const SizedBox(height: 50),

                        Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE4EC), // light pink background
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(4, 4),
                                  blurRadius: 8,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),

                          child: TextFormField(
                            controller: _controllerEmail,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.patrickHand(),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.patrickHand(),
                              hintText: 'Enter email',
                              hintStyle: GoogleFonts.patrickHand(),
                              prefixIcon: const Icon(Icons.email),
                         // REMOVE black border by overriding all border states
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                          ),
                        ),   
                        const SizedBox(height: 20),

                            Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE4EC), // light pink background
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(4, 4),
                                  blurRadius: 8,
                                ),
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child:TextFormField(
                          controller: _controllerPassword,
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
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              final email = _controllerEmail.text.trim();

                              if (email.isEmpty || !email.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Please enter a valid email to reset password.")),
                                );
                                return;
                              }

                              try {
                                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Password reset email sent. Check your inbox.")),
                                );
                              } on FirebaseAuthException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message ?? "An error occurred.")),
                                );
                              }
                            },
                            child: Text(
                              "Forgot password?",
                              style: GoogleFonts.patrickHand(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                                              
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
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 175, 69, 105),
                                        Color.fromARGB(255, 228, 157, 181)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(4, 4),
                                      ),     
                                  BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                ),
                              ],
                            
                                  ),
                                  child: MaterialButton(
                                    onPressed: signInWithEmailAndPassword,
                                    textColor: Colors.black,
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
                            ],
                          ),
                        ),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: GoogleFonts.patrickHand(
                              fontSize: 16,
                              color: Colors.black87,
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
                            'SIGN UP',
                            style: GoogleFonts.patrickHand(
                              fontSize: 16,
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.pink,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                      ],
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
      )
    );
  }
}
