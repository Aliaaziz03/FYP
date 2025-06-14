import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerPage extends StatelessWidget {
  final String modelPath;
  final Map<String, String> clothDetails;

  const ModelViewerPage({
    required this.modelPath,
    required this.clothDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("3D Cloth Viewer"),
        backgroundColor: Colors.pink[50],
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.pink[50],
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: ModelViewer(
              src: modelPath,
              alt: "3D Model of Clothes",
              ar: false,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.white,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cloth Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...clothDetails.entries.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(child: Text(entry.value)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
