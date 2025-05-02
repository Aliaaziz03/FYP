import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_apps/Screen_flow/AR_background/AvatarViewer.dart';
import 'package:fyp_apps/Screen_flow/authentication/SignIn.dart';
import 'package:fyp_apps/Screen_flow/3Davatar/MatchAvatar.dart';
import 'package:fyp_apps/Screen_flow/3Davatar/input.dart';
import 'package:fyp_apps/Screen_flow/Profile.dart';

class WardrobePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wardrobe")),
      body: Center(child: Text("Wardrobe Page")),
    );
  }
}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  int _focusedIndex = 0;
  String _selectedAvatar = 'assets/avatars/avatar1.png'; // default

void _updateAvatar(String newAvatar) {
    setState(() {
      _selectedAvatar = newAvatar;
    });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading:GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfilePage(currentAvatar: _selectedAvatar),
              ),
            );
            if (result != null) {
              _updateAvatar(result);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(_selectedAvatar),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Signin()),
              );
            },
          ),
        ],
      )
      : null,
      body: _buildPageContent(_selectedIndex),

    
    );
  }

  Widget _buildPageContent(int index) {
    final String backgroundImage = 'assets/bg.png';

    final List<Map<String, String>> categories = [
      {'image': 'assets/sports.png', 'label': '3D avatar'},
      {'image': 'assets/cultural.png', 'label': 'Wardrobe'},
      {'image': 'assets/education.png', 'label': 'Find your outfit'},
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: categories.length,
                  controller: PageController(viewportFraction: 0.5),
                  onPageChanged: (int newIndex) {
                    setState(() {
                      _focusedIndex = newIndex;
                    });
                  },
                  itemBuilder: (context, i) {
                    final String label = categories[i]['label']!;
                    final String imagePath = categories[i]['image']!;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Opacity(
                        opacity: i == _focusedIndex ? 1.0 : 0.6,
                        child: Transform.scale(
                          scale: i == _focusedIndex ? 1.2 : 1.0,
                          child: GestureDetector(
                            onTap: () => _handleNavigation(context, label),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: i == _focusedIndex ? 300 : 200,
                                  height: i == _focusedIndex ? 250 : 200,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 235, 161, 186),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(50.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: i == _focusedIndex ? 20 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

 void _handleNavigation(BuildContext context, String label) async {
  Widget destination;

  switch (label) {
    case '3D avatar':
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = doc.data();

        // Check if the required measurement fields exist and are not empty
        if (doc.exists &&
            data != null &&
            data['height'] != null &&
            data['hip'] != null &&
            data['chest'] != null &&
            data['waist'] != null &&
            data['height'].toString().isNotEmpty &&
            data['hip'].toString().isNotEmpty &&
            data['chest'].toString().isNotEmpty &&
            data['waist'].toString().isNotEmpty) {

          destination = AvatarMatcherPage();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Measurements Required"),
              content: Text("You need to fill in your body measurements before accessing the 3D Avatar."),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text("Fill Now"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MeasurementInputPage()),
                    );
                  },
                ),
              ],
            ),
          );
        }
      }
      return; // Skip default navigation
    case 'Wardrobe':
      destination = WardrobePage();
      break;
    case 'Find your outfit':
      destination = AvatarViewerScreen();
      break;
    default:
      destination = Scaffold(body: Center(child: Text('Page not found')));
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => destination),
  );
}}
