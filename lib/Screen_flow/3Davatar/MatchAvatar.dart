import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_apps/Screen_flow/HomeScreen.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AvatarMatcherPage extends StatefulWidget {
  @override
  _AvatarMatcherPageState createState() => _AvatarMatcherPageState();
}

class _AvatarMatcherPageState extends State<AvatarMatcherPage> with TickerProviderStateMixin {
  String? matchedSize;
  bool isLoading = true;
  bool showCurtain = true;

  late AnimationController _curtainController;
  late Animation<double> _curtainAnimation;

  @override
  void initState() {
    super.initState();
    _curtainController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _curtainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _curtainController, curve: Curves.easeInOut),
    );

    fetchAndMatchMeasurements();
  }

  @override
  void dispose() {
    _curtainController.dispose();
    super.dispose();
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

    await Future.delayed(Duration(milliseconds: 500));
    _curtainController.forward().then((_) {
      setState(() {
        showCurtain = false;
      });
    });
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
        if (value < 152.25) return 1;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgView.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // 3D avatar viewer (ModelViewer)
            if (!isLoading && matchedSize != null)
              Positioned.fill(
                child: FutureBuilder<String>(
                  future: getLocalModelPath(getAvatarAssetPath(matchedSize!)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ModelViewer(
                      src: 'file://${snapshot.data!}',
                      alt: "A 3D avatar",
                      ar: false,
                      autoRotate: true,
                      cameraControls: true,
                      disableZoom: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                ),
              ),

            // Loading spinner
            if (isLoading)
              Center(child: CircularProgressIndicator()),

            // Match size label
            if (!isLoading && matchedSize != null)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Your matched size is: $matchedSize",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Fallback if no matched size
            if (!isLoading && matchedSize == null)
              Center(
                child: Text(
                  "Could not retrieve measurements.",
                  style: TextStyle(color: Colors.white),
                ),
              ),

            // Curtain animation
            if (showCurtain)
              AnimatedBuilder(
                animation: _curtainAnimation,
                builder: (context, child) {
                  double curtainWidth = MediaQuery.of(context).size.width / 2;
                  return Stack(
                    children: [
                      Positioned(
                        left: -curtainWidth * _curtainAnimation.value,
                        top: 0,
                        bottom: 0,
                        width: curtainWidth,
                        child: Image.asset(
                          'assets/curtain.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      Positioned(
                        right: -curtainWidth * _curtainAnimation.value,
                        top: 0,
                        bottom: 0,
                        width: curtainWidth,
                        child: Image.asset(
                          'assets/curtain.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.centerLeft,
                        ),
                      ),

                    ],
                  );
                },
              ),

            // Top-left "X" close button
            if(!showCurtain)
            Positioned(
              top: 30,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
