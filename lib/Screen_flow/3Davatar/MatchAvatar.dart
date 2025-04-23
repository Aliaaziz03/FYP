import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvatarMatcherPage extends StatefulWidget {
  @override
  _AvatarMatcherPageState createState() => _AvatarMatcherPageState();
}

class _AvatarMatcherPageState extends State<AvatarMatcherPage> {
  String? matchedSize;
  bool isLoading = true;

  String getAvatarPath(String size) {
    return 'assets/avatar/avatar_${size.toLowerCase()}.glb';
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
      isLoading = false;
    });
  }

  /// Determine the size based on the largest category
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

  /// Size score: 1 = S, 2 = M, 3 = L, 4 = XL
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Matched 3D Avatar")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : matchedSize != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Your matched size is: $matchedSize",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Image.asset(getAvatarPath(matchedSize!)), // Replace with 3D viewer if using model viewer
                    ],
                  )
                : Text("Could not retrieve measurements."),
      ),
    );
  }
}
