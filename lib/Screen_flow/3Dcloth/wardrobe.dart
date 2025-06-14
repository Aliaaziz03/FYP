import 'package:flutter/material.dart';
import 'package:fyp_apps/Screen_flow/3Dcloth/ClothesViewer.dart';

class WardrobePage extends StatelessWidget {
  // Sample clothes images
  final List<String> clothes = [
    'assets/clothes/floral.png',
    'assets/clothes/songket.png',
    'assets/clothes/silk.png',
    'assets/clothes/lace.png',
  ];

  // Matching 3D model paths for each item (must be .glb files in assets)
  final List<String> modelPaths = [
    'assets/clothes/floral.glb',
    'assets/clothes/songket.glb',
    'assets/clothes/silk.glb',
    'assets/clothes/lace.glb',
  ];

  // Metadata for each cloth
  final List<Map<String, String>> clothDetailsList = [
    {
      'Material': 'Cotton',
      'Pattern': 'Floral',
      'Color': 'blue, cream',
      'Type': 'Baju kurung moden',
    },
    {
      'Material': 'Cotton',
      'Pattern': 'Geometry',
      'Color': 'red, yellow',
      'Type': 'Baju kurung moden',
    },
    {
      'Material': 'Silk',
      'Pattern': 'Floral',
      'Color': 'grey',
      'Type': 'Baju kurung moden',
    },
    {
      'Material': 'Lace',
      'Pattern': 'Floral',
      'Color': 'white, black',
      'Type': 'Baju kurung moden',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Wardrobe'),
        backgroundColor: Colors.pink[50],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.pink[50],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: clothes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModelViewerPage(
                      modelPath: modelPaths[index],
                      clothDetails: clothDetailsList[index],
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(4, 4),
                    ),
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      offset: Offset(-4, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    clothes[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
