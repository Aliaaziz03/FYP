import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Capture and share the screenshot from the provided key
Future<void> captureAndShareScreenshot(GlobalKey boundaryKey) async {
  try {
    RenderRepaintBoundary boundary =
        boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/ar_model_screenshot.png');
    await file.writeAsBytes(pngBytes);

    Share.shareXFiles([XFile(file.path)], text: 'Check out this 3D Avatar in AR!');
  } catch (e) {
    print("❌ Error capturing screenshot: $e");
  }
}
