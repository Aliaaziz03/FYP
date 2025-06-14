import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';


class ClothingItem {
  final String name;
  final String imagePath;
  final List<String> availableSizes;

  ClothingItem({
    required this.name,
    required this.imagePath,
    required this.availableSizes,
  });
}

class MatcherPage extends StatefulWidget {
  @override
  _MatcherPageState createState() => _MatcherPageState();
}

class _MatcherPageState extends State<MatcherPage> {
  String? matchedSize;
  String? selectedClothingName;
  String? selectedSizeForClothes;
  bool isLoading = true;

  final List<ClothingItem> clothingItems = [
    ClothingItem(
      name: 'Cotton',
      imagePath: 'assets/clothes/floral.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
    ),
    ClothingItem(
      name: 'Silk',
      imagePath: 'assets/clothes/silk.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
    ),
    ClothingItem(
      name: 'Songket',
      imagePath: 'assets/clothes/songket.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
    ),
    ClothingItem(
      name: 'Lace',
      imagePath: 'assets/clothes/lace.png',
      availableSizes: ['S', 'M', 'L', 'XL'],
    ),
  ];

  final Map<String, Map<String, String>> clothingMeasurements = {
    'S': {
      'Shoulder': '15"',
      'Hip': '36"',
      'Chest': '39"',
      'Waist': '26"',
      'Skirt length': '39"',
      'Sleeve length': '22"',
      'Top length': '39"',
    },
    'M': {
      'Shoulder': '16"',
      'Hip': '41"',
      'Chest': '42"',
      'Waist': '28"',
      'Skirt length': '40"',
      'Sleeve length': '22"',
      'Top length': '40"',
    },
    'L': {
      'Shoulder': '17"',
      'Hip': '44"',
      'Chest': '46"',
      'Waist': '30"',
      'Skirt length': '40"',
      'Sleeve length': '23"',
      'Top length': '41"',
    },
    'XL': {
      'Shoulder': '18"',
      'Hip': '48"',
      'Chest': '50"',
      'Waist': '32"',
      'Skirt length': '41"',
      'Sleeve length': '23"',
      'Top length': '42"',
    },
  };

  List<Widget> buildMeasurementView(String size) {
    final measurements = clothingMeasurements[size];
    if (measurements == null) return [];

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: measurements.entries.map((entry) {
                return Chip(
                  label: Text("${entry.key}: ${entry.value}"),
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.black12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ];
  }

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
      selectedClothingName = 'Floral'; // auto-apply floral
      selectedSizeForClothes = size;   // match avatar size
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
      case 1:
        return "S";
      case 2:
        return "M";
      case 3:
        return "L";
      case 4:
        return "XL";
      default:
        return "S";
    }
  }

  int getSizeScore(double value, String type) {
    switch (type) {
      case "height":
        if (value < 152.5) return 1;
        if (value < 153.5) return 2;
        if (value < 154.75) return 3;
        return 4;
      case "hip":
        if (value < 86) return 1;
        if (value < 100) return 2;
        if (value < 113) return 3;
        return 4;
      case "chest":
        if (value < 86) return 1;
        if (value < 100) return 2;
        if (value < 113) return 3;
        return 4;
      case "waist":
        if (value < 66) return 1;
        if (value < 86) return 2;
        if (value < 117) return 3;
        return 4;
      default:
        return 1;
    }
  }

  String getCombinedModelPath(String clothingName, String clothingSize, String avatarSize) {
    return 'assets/match/${clothingName.toLowerCase()}_${clothingSize.toLowerCase()}_${avatarSize.toLowerCase()}.glb';
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
        backgroundColor: Colors.pink[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Choose clothes size",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: item.availableSizes.map((size) {
              final isSelected = selectedSizeForClothes == size;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      selectedClothingName = item.name;
                      selectedSizeForClothes = size;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.pink[400] : Colors.pink[100],
                    foregroundColor: isSelected ? Colors.white : Colors.pink[900],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: isSelected ? 6 : 2,
                  ),
                  child: Text(
                    size,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    },
  );
}


  void openARViewer(String clothingName, String clothingSize, String avatarSize) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARViewerPage(
          clothingName: clothingName,
          clothingSize: clothingSize,
          avatarSize: avatarSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? displayModelPath;
    if (matchedSize != null && selectedClothingName != null && selectedSizeForClothes != null) {
      displayModelPath = getCombinedModelPath(selectedClothingName!, selectedSizeForClothes!, matchedSize!);
    }

    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.black),
                          SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Your Avatar Size: $matchedSize",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  if (selectedSizeForClothes != null) ...[
                    SizedBox(height: 4),
                    Center(
                      child: Text(
                        "Chosen Clothes Size: $selectedSizeForClothes",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            height: 400,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: FutureBuilder<String>(
key: ValueKey(displayModelPath ?? matchedSize),
future: displayModelPath != null
    ? getLocalModelPath(displayModelPath)
    : getLocalModelPath('assets/avatar/avatar_${matchedSize!.toLowerCase()}.glb'),

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
if (displayModelPath != null)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
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
              onPressed: () => openARViewer(
                selectedClothingName!,
                selectedSizeForClothes!,
                matchedSize!,
              ),
              textColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Try in AR',
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

                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
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
                          if (selectedSizeForClothes != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                "Clothes measurement details:",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                children: buildMeasurementView(selectedSizeForClothes!),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}


class ARViewerPage extends StatefulWidget {
  final String clothingName;
  final String clothingSize;
  final String avatarSize;

  const ARViewerPage({
    Key? key,
    required this.clothingName,
    required this.clothingSize,
    required this.avatarSize,
  }) : super(key: key);

  @override
  State<ARViewerPage> createState() => _ARViewerPageState();
}

class _ARViewerPageState extends State<ARViewerPage> {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> shareScreenshot() async {
    final image = await screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/shared_model.png').create();
    await imagePath.writeAsBytes(image);

    await Share.shareXFiles([XFile(imagePath.path)], text: 'Check out my 3D model in AR!');
  }

  @override
  Widget build(BuildContext context) {
    final String modelUrl =
        'https://fyp-apps-53f7c.web.app/${widget.clothingName.toLowerCase()}_${widget.clothingSize.toLowerCase()}_${widget.avatarSize.toLowerCase()}.glb';

    return Scaffold(
      appBar: AppBar(
        title: Text("AR View"),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: shareScreenshot,
          ),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: ModelViewer(
          src: modelUrl,
          alt: "AR Model",
          ar: true,
          arModes: ['scene-viewer', 'webxr', 'quick-look'],
          autoRotate: true,
          cameraControls: true,
          disableZoom: false,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}