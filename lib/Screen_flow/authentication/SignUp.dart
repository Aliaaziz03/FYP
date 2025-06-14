import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_apps/Screen_flow/3Davatar/input.dart';
import 'package:fyp_apps/Screen_flow/authentication/SignIn.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_apps/Screen_flow/3Davatar/input.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserWithEmailAndPassword() async {
    String name = _controllerName.text.trim();
    String email = _controllerEmail.text.trim();
    String password = _controllerPassword.text.trim();
    String confirmPassword = _controllerConfirmPassword.text.trim();

    if (password != confirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match.";
      });
      return;
    }

    try {
      // Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        print("User registered successfully.");
        
        // Store additional user data in Firestore
        await _firestore.collection("users").doc(userCredential.user!.uid).set({
          "email" : email,
          "name" : name,
        });

        print("Firestore data written successfully.");

        // Navigate to Login Page
        setState(() {
          errorMessage = null; // Clear any error messages
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MeasurementInputPage()),
        );
      } else {
        print("Error: UserCredential.user is null.");
        setState(() {
          errorMessage = "Unexpected error occurred.";
        });
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      setState(() {
        errorMessage = e.message ?? "An unknown error occurred.";
      });
    } catch (e) {
      print("General Exception: $e");
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Signin()), // Navigate to the previous screen
            );
          },
        ),
      ),
      body: Container(
                  color: Colors.pink.withOpacity(0.1), // Background color
                child:SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign Up',
                            style: GoogleFonts.patrickHand(
                              fontSize: 40,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                         
                       Container(
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
                            
                            Form(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                                child: Column(
                                  children: [
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
                                      controller: _controllerName,
                                      keyboardType: TextInputType.name,
                                      style: GoogleFonts.patrickHand(),
                                      decoration: InputDecoration(
                                        labelText: 'Name',
                                        labelStyle: GoogleFonts.patrickHand(),
                                        hintText: 'Enter Name',
                                        hintStyle: GoogleFonts.patrickHand(),
                                        prefixIcon: const Icon(Icons.person_2),
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
                                      validator: (value) {
                                        return value!.isEmpty ? 'Please enter name' : null;
                                      },
                                    ),),
                                        
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
                                 child: TextFormField(
                                      controller: _controllerEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      style: GoogleFonts.patrickHand(),
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle: GoogleFonts.patrickHand(),
                                        hintText: 'Enter Email',
                                        hintStyle: GoogleFonts.patrickHand(),
                                        prefixIcon: const Icon(Icons.badge),
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
                                      validator: (value) {
                                        return value!.isEmpty ? 'Please enter email' : null;
                                      },
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
                                      validator: (value) {
                                        return value!.isEmpty ? 'Please enter password' : null;
                                      },
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
                                      controller: _controllerConfirmPassword,
                                      keyboardType: TextInputType.visiblePassword,
                                      obscureText: true,
                                      style: GoogleFonts.patrickHand(),
                                      decoration: InputDecoration(
                                        labelText: 'Confirm Password',
                                        labelStyle: GoogleFonts.patrickHand(),
                                        hintText: 'Confirm password',
                                        hintStyle: GoogleFonts.patrickHand(),
                                        prefixIcon: const Icon(Icons.lock_outline),
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
                                      validator: (value) {
                                        return value!.isEmpty ? 'Please confirm password' : null;
                                      },
                                    ),
                              ),
                                    const SizedBox(height: 20),
                                        
                                    if (errorMessage != null && errorMessage!.isNotEmpty)
                                      Text(
                                        errorMessage!,
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                      ),
                                    const SizedBox(height: 0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                                          minWidth: double.infinity,
                                          onPressed: () async {
                                            if (_controllerEmail.text.isEmpty) {
                                              setState(() => errorMessage = "Please enter a valid email.");
                                              return;
                                            } else {
                                              createUserWithEmailAndPassword();
                                            }
                                          },
                                          textColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: const Text(
                                            'Sign Up',
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
                            ),
                          ],
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
