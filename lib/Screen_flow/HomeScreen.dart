import 'package:flutter/material.dart';
import 'package:fyp_apps/Screen_flow/authentication/SignIn.dart';

// Dummy pages for navigation
class AvatarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("3D Avatar")),
      body: Center(child: Text("3D Avatar Page")),
    );
  }
}

class WardrobePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wardrobe")),
      body: Center(child: Text("Wardrobe Page")),
    );
  }
}

class OutfitFinderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Find Your Outfit")),
      body: Center(child: Text("Find Your Outfit Page")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Signin()),
                  );
                },
              ),
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
                            onTap: () {
                              Widget destination;

                              switch (label) {
                                case '3D avatar':
                                  destination = AvatarPage();
                                  break;
                                case 'Wardrobe':
                                  destination = WardrobePage();
                                  break;
                                case 'Find your outfit':
                                  destination = OutfitFinderPage();
                                  break;
                                default:
                                  destination = Scaffold(
                                      body: Center(child: Text('Page not found')));
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => destination),
                              );
                            },
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
}
