import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fyp_apps/Screen_flow/HomeScreen.dart';

class MeasurementInputPage extends StatefulWidget {
  const MeasurementInputPage({super.key});

  @override
  State<MeasurementInputPage> createState() => _MeasurementInputPageState();
}

class _MeasurementInputPageState extends State<MeasurementInputPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveMeasurements() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('measurements').doc(user.uid).set({
      'height': _heightController.text.trim(),
      'hip': _hipController.text.trim(),
      'chest': _chestController.text.trim(),
      'waist': _waistController.text.trim(),
      'email': user.email,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Measurements saved successfully!')),
    );

        // Navigate to home or profile or next screen
    Navigator.pop(context);
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
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
        controller: controller,
        keyboardType: TextInputType.number,
        style: GoogleFonts.patrickHand(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.patrickHand(),
          hintText: 'Enter $label',
          hintStyle: GoogleFonts.patrickHand(),
          prefixIcon: const Icon(Icons.straighten),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.withOpacity(0.1),
        actions: [
          TextButton(
            onPressed: () {
   // Navigate to HomeScreen directly after saving measurements
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  HomeScreen()),
    );            },
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.pink.withOpacity(0.1),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter Your Measurements',
                    style: GoogleFonts.patrickHandSc(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField('Height (cm)', _heightController),
                  _buildTextField('Hip (cm)', _hipController),
                  _buildTextField('Chest (cm)', _chestController),
                  _buildTextField('Waist (cm)', _waistController),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
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
                      onPressed: _saveMeasurements,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Save Measurements',
                        style: GoogleFonts.patrickHand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
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
