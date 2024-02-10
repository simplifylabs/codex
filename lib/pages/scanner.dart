// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:codex/util/ad.dart';
import 'package:flutter/material.dart' hide Card;
import 'dart:io' show Platform;
import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';
import 'package:codex/util/barcode.dart';
import 'package:codex/util/card.dart';

class Scanner extends StatelessWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        BarcodeCamera(
          types: Platform.isIOS ? Types.ios : Types.android,
          resolution: Resolution.hd720,
          framerate: Framerate.fps60,
          mode: DetectionMode.pauseVideo,
          onScan: (code) async {
            if (Ad.isReady) await Ad.show();

            var card = Card.generate(code.value);
            await card.preview(context, true, () {
              CameraController.instance.resumeDetector();
            });
          },
          children: [
            const MaterialPreviewOverlay(animateDetection: false),
          ],
        ),
        Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 5,
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ))),
      ],
    ));
  }
}
