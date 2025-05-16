import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vector_math/vector_math_64.dart' ;
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';



final GlobalKey<_ARAvatarViewerState> arViewerKey = GlobalKey<_ARAvatarViewerState>();

class AvatarViewerScreen extends StatelessWidget {
  const AvatarViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D Avatar in AR',
        style: GoogleFonts.patrickHand(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final state = arViewerKey.currentState;
                  state?.shareARModelScreenshot();
                },
              );
            },
          ),
        ],
      ),
      body: ARAvatarViewer(key: arViewerKey),
    );
  }
}

class ARAvatarViewer extends StatefulWidget {
  const ARAvatarViewer({super.key});

  @override
  State<ARAvatarViewer> createState() => _ARAvatarViewerState();
}

class _ARAvatarViewerState extends State<ARAvatarViewer> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  ARNode? modelNode;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: ARView(
        onARViewCreated: onARViewCreated,
      ),
    );
  }

  void onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) async {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    await arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: true,
      handleTaps: false,
    );

    await arObjectManager.onInitialize();

    modelNode = ARNode(
      name: "avatar_node",
      type: NodeType.webGLB,
      uri: "https://fyp-apps-53f7c.web.app/floral_s_s.glb",
      position: Vector3(0.0, 0.0, -1.0),
      rotation: Vector4(0.0, 1.0, 0.0, 0.0),
      scale: Vector3(1.0, 1.0, 1.0),
    );

    bool? didAdd = await arObjectManager.addNode(modelNode!);
    if (didAdd == true) {
      startFollowingCamera();
    }
  }

  void startFollowingCamera() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      final cameraPose = await arSessionManager.getCameraPose();
      if (cameraPose == null) return true;

      final forward = Vector3(0.0, 0.0, -1.0);
      final newPosition = cameraPose.transform3(forward);

      if (modelNode != null) {
        await arObjectManager.removeNode(modelNode!);
      }

      modelNode = ARNode(
        name: "avatar_node",
        type: NodeType.webGLB,
        uri: "https://fyp-apps-53f7c.web.app/floral_s_s.glb",
        position: newPosition,
        rotation: Vector4(0.0, 1.0, 0.0, 0.0),
        scale: Vector3(1.0, 1.0, 1.0),
      );

      await arObjectManager.addNode(modelNode!);
      return true;
    });
  }

  Future<void> captureScreenshot() async {
    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/ar_model_screenshot.png');
      await file.writeAsBytes(pngBytes);

      shareScreenshot(file);
    } catch (e) {
      print("❌ Error capturing screenshot: $e");
    }
  }

  void shareScreenshot(File file) {
    Share.shareXFiles([XFile(file.path)], text: 'Check out this 3D Avatar in AR!');
  }

  Future<void> shareARModelScreenshot() async {
    await captureScreenshot();
  }
}
