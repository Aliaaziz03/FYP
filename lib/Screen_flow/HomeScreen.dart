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
  String _username = '';
  int _selectedIndex = 1;
  int _focusedIndex = 0;
  String _selectedAvatar = 'assets/avatars/avatar1.png'; // default

  void _updateAvatar(String newAvatar) {
    setState(() {
      _selectedAvatar = newAvatar;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchAvatar(); 
  }

  void _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['name'] != null) {
        setState(() {
          _username = doc['name'];
        });
      }
    }
  }
  void _fetchAvatar() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data()?['avatar'] != null) {
      setState(() {
        _selectedAvatar = doc['avatar']; // Assumes avatar is stored as a string path in Firestore
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1
          ? AppBar(
              backgroundColor: Colors.pink.withOpacity(0.1),
              elevation: 0,
              leading: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(currentAvatar: _selectedAvatar),
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
    final List<Map<String, String>> categories = [
      {'image': 'assets/HomeAvatar.png', 'label': '3D avatar'},
      {'image': 'assets/HomeWardrobe.png', 'label': 'Wardrobe'},
      {'image': 'assets/HomeMatch.png', 'label': 'Find your outfit'},
    ];

    return Stack(
      children: [
        Container(
          color: Colors.pink.withOpacity(0.1), // Light pink background
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the left
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Hello,',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {


                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          final username = data['name'] ?? 'User';
                          return Text(
                            username,
                            style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                          );
                        }

                        return Text('User not found');
                      },
                    ),
                  ],
                ),
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
                 Image.asset(
  imagePath,
  width: i == _focusedIndex ? 300 : 200,
  height: i == _focusedIndex ? 250 : 200,
  fit: BoxFit.contain,
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
        ),
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
  builder: (context) => Dialog(
    backgroundColor: Colors.transparent, // Makes the dialog background transparent
    child: Container(
      decoration: BoxDecoration(
          color: Colors.pinkAccent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Measurements Required !",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "You need to fill in your body measurements before accessing the 3D Avatar.",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
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
        ],
      ),
    ),
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
  }
}
