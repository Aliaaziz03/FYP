import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ClothingItem {
  final String name;
  final String imagePath;
  final List<String> availableSizes;
  final Map<String, String> modelPaths;

  ClothingItem({
    required this.name,
    required this.imagePath,
    required this.availableSizes,
    required this.modelPaths,
  });
}

class MatcherPage extends StatefulWidget {
  @override
  _MatcherPageState createState() => _MatcherPageState();
}

class _MatcherPageState extends State<MatcherPage> {
  String? matchedSize;
  String? selectedClothingModel;
  bool isLoading = true;

  final List<ClothingItem> clothingItems = [
    ClothingItem(
      name: 'Floral',
      imagePath: 'assets/clothes/floral.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      modelPaths: {
        'S': 'assets/clothes_models/sweater_brown_s.glb',
        'M': 'assets/clothes_models/sweater_brown_m.glb',
        'L': 'assets/clothes_models/sweater_brown_l.glb',
        'XL': 'assets/clothes_models/sweater_brown_xl.glb',
      },
    ),
    ClothingItem(
      name: 'Floral',
      imagePath: 'assets/clothes/floral.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      modelPaths: {
        'S': 'assets/clothes_models/sweater_brown_s.glb',
        'M': 'assets/clothes_models/sweater_brown_m.glb',
        'L': 'assets/clothes_models/sweater_brown_l.glb',
        'XL': 'assets/clothes_models/sweater_brown_xl.glb',
      },
    ),
        ClothingItem(
      name: 'Silk',
      imagePath: 'assets/clothes/silk.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      modelPaths: {
        'S': 'assets/clothes_models/sweater_brown_s.glb',
        'M': 'assets/clothes_models/sweater_brown_m.glb',
        'L': 'assets/clothes_models/sweater_brown_l.glb',
        'XL': 'assets/clothes_models/sweater_brown_xl.glb',
      },
    ),
        ClothingItem(
      name: 'Songket',
      imagePath: 'assets/clothes/songket.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      modelPaths: {
        'S': 'assets/clothes_models/sweater_brown_s.glb',
        'M': 'assets/clothes_models/sweater_brown_m.glb',
        'L': 'assets/clothes_models/sweater_brown_l.glb',
        'XL': 'assets/clothes_models/sweater_brown_xl.glb',
      },
    ),
    ClothingItem(
      name: 'Lace',
      imagePath: 'assets/clothes/lace.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
      modelPaths: {
        'S': 'assets/clothes_models/cardigan_green_s.glb',
        'M': 'assets/clothes_models/cardigan_green_m.glb',
        'L': 'assets/clothes_models/cardigan_green_l.glb',
        'XL': 'assets/clothes_models/cardigan_green_xl.glb',
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchAndMatchMeasurements();
  }

  Future<void> fetchAndMatchMeasurements() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final double height = double.tryParse(data["height"] ?? "") ?? 0;
    final double hip = double.tryParse(data["hip"] ?? "") ?? 0;
    final double chest = double.tryParse(data["chest"] ?? "") ?? 0;
    final double waist = double.tryParse(data["waist"] ?? "") ?? 0;

    final size = getLargestMatchingSize(height, hip, chest, waist);

    setState(() {
      matchedSize = size;
      isLoading = false;
    });
  }

  String getLargestMatchingSize(double height, double hip, double chest, double waist) {
    int heightScore = getSizeScore(height, "height");
    int hipScore = getSizeScore(hip, "hip");
    int chestScore = getSizeScore(chest, "chest");
    int waistScore = getSizeScore(waist, "waist");

    int maxScore = [heightScore, hipScore, chestScore, waistScore].reduce((a, b) => a > b ? a : b);

    switch (maxScore) {
      case 1: return "S";
      case 2: return "M";
      case 3: return "L";
      case 4: return "XL";
      default: return "S";
    }
  }

  int getSizeScore(double value, String type) {
    switch (type) {
      case "height":
        if (value < 155) return 1;
        if (value < 165) return 2;
        if (value < 175) return 3;
        return 4;
      case "hip":
        if (value < 85) return 1;
        if (value < 95) return 2;
        if (value < 105) return 3;
        return 4;
      case "chest":
        if (value < 85) return 1;
        if (value < 95) return 2;
        if (value < 105) return 3;
        return 4;
      case "waist":
        if (value < 70) return 1;
        if (value < 80) return 2;
        if (value < 90) return 3;
        return 4;
      default:
        return 1;
    }
  }

  String getAvatarAssetPath(String size) {
    return 'assets/avatar/avatar_${size.toLowerCase()}.glb';
  }

  Future<String> getLocalModelPath(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile.path;
  }

void showSizePicker(ClothingItem item) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Pilih saiz untuk ${item.name}"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: item.availableSizes.map((size) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedClothingModel = item.modelPaths[size];
                });
              },
              child: Text(size),
            );
          }).toList(),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 30),
                Text(
                  "Saiz padanan anda: $matchedSize",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                SizedBox(height: 10),
                Container(
                  height: 750,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FutureBuilder<String>(
                    future: getLocalModelPath(
                      selectedClothingModel ?? getAvatarAssetPath(matchedSize!),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return ModelViewer(
                        src: 'file://${snapshot.data!}',
                        alt: "3D Model",
                        ar: false,
                        autoRotate: true,
                        cameraControls: true,
                        disableZoom: false,
                        backgroundColor: Colors.white,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
                  child: SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: clothingItems.length,
                      itemBuilder: (context, index) {
                        final item = clothingItems[index];
                        return GestureDetector(
                          onTap: () => showSizePicker(item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              width: 120,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black),
                                color: Colors.grey[200],
                                image: DecorationImage(
                                  image: AssetImage(item.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: Colors.black.withOpacity(0.6),
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                child: Text(
                                  item.name,
                                  style: TextStyle(fontSize: 12, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
