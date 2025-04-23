import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final String currentAvatar;

  ProfilePage({required this.currentAvatar});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String selectedAvatar = '';
  bool showAvatars = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();

  final List<String> avatarList = [
    'assets/profile/avatar 1.png',
    'assets/profile/avatar 2.png',
    'assets/profile/avatar 3.png',
    'assets/profile/avatar 4.png',
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    selectedAvatar = widget.currentAvatar;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _heightController.text = data['height'] ?? '';
        _hipController.text = data['hip'] ?? '';
        _chestController.text = data['chest'] ?? '';
        _waistController.text = data['waist'] ?? '';
        setState(() {
          selectedAvatar = data['avatar'] ?? widget.currentAvatar;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'height': _heightController.text.trim(),
        'hip': _hipController.text.trim(),
        'chest': _chestController.text.trim(),
        'waist': _waistController.text.trim(),
        'avatar': selectedAvatar,
      }, SetOptions(merge: true));

      Navigator.pop(context, selectedAvatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  showAvatars = !showAvatars;
                });
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(selectedAvatar),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 20),
            if (showAvatars)
              Center(
                    child: Wrap(
      spacing: 16,
      alignment: WrapAlignment.center,
      children: avatarList.map((avatar) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedAvatar = avatar;
            });
          },
               child: CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(avatar),
            backgroundColor: selectedAvatar == avatar ? Colors.blueAccent : Colors.transparent,
          ),
        );
      }).toList(),
    ),
  ),
            const SizedBox(height: 30),
            _buildInputField("Name", _nameController),
            const SizedBox(height: 15),
            _buildInputField("Height (cm)", _heightController),
            const SizedBox(height: 15),
            _buildInputField("Hip (cm)", _hipController),
            const SizedBox(height: 15),
            _buildInputField("Chest (cm)", _chestController),
            const SizedBox(height: 15),
            _buildInputField("Waist (cm)", _waistController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Save Profile", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.person_outline),
      ),
    );
  }
}
