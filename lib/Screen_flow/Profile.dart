import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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
    'assets/profile/avatar 1.jpg',
    'assets/profile/avatar 2.jpg',
    'assets/profile/avatar 3.jpg',
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
      appBar: AppBar(
        title: Text('PROFILE PAGE',
        style: GoogleFonts.patrickHand(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          )),
        backgroundColor: Colors.pink.withOpacity(0.1),
      ),
      body: Container(
          height: double.infinity,
        color: Colors.pink.withOpacity(0.1),
        child: SingleChildScrollView(
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
                  radius: 80,
                  backgroundImage: AssetImage(selectedAvatar),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 20),
              if (showAvatars)
                Wrap(
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
                        backgroundColor: selectedAvatar == avatar
                            ? Colors.blueAccent
                            : Colors.transparent,
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 30),
              _buildInputField("Name", _nameController, TextInputType.text),
              const SizedBox(height: 15),
              _buildInputField("Height (cm)", _heightController, TextInputType.number),
              const SizedBox(height: 15),
              _buildInputField("Hip (cm)", _hipController, TextInputType.number),
              const SizedBox(height: 15),
              _buildInputField("Chest (cm)", _chestController, TextInputType.number),
              const SizedBox(height: 15),
              _buildInputField("Waist (cm)", _waistController, TextInputType.number),
              const SizedBox(height: 30),
              Padding(
  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: _saveProfile,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
            child: Text(
              "Save Profile",
              style: GoogleFonts.patrickHand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    ),
  ),
),

 
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, TextInputType type) {
  return Container(
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
      keyboardType: type,
      style: GoogleFonts.patrickHand(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.patrickHand(),
        hintText: 'Enter $label',
        hintStyle: GoogleFonts.patrickHand(),
        prefixIcon: Icon(
          label == "Name" ? Icons.person : Icons.straighten,
        ),
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

}
