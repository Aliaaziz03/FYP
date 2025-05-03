/*import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class AvatarViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('3D Avatar Viewer')),
      body: Center(
        child: ModelViewer(
          src: 'assets/avatar/avatar_S.glb',
          alt: "A 3D avatar",
          ar: false,
          autoRotate: true,
          cameraControls: true,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    await _firestore.collection("users").doc(user.uid).update({
      "height": _heightController.text.trim(),
      "hip": _hipController.text.trim(),
      "chest": _chestController.text.trim(),
      "waist": _waistController.text.trim(),
    });

    // Navigate to home or profile or next screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Your Measurements"),
        backgroundColor: Colors.pink.withOpacity(0.1),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Skip and go back
            },
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
      color: Colors.pink.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildInputField("Height (cm)", _heightController),
              const SizedBox(height: 20),
              _buildInputField("Hip (cm)", _hipController),
              const SizedBox(height: 20),
              _buildInputField("Chest (cm)", _chestController),
              const SizedBox(height: 20),
              _buildInputField("Waist (cm)", _waistController),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveMeasurements,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Save Measurements",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.straighten),
      ),
    );
  }
}