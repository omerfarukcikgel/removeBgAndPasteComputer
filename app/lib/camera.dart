import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:removeBgAndPasteComputer/finish.dart';
import 'package:removeBgAndPasteComputer/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraScreen(this.cameras);

  @override
  CameraScreenState createState() {
    return new CameraScreenState();
  }
}

List<int> imageBytesLast;
List<int> imageBytes1;

class CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  String imgLast = "";
  String noBgImgLast = "";

  ScreenshotController screenshotController = ScreenshotController();
  @override
  void initState() {
    super.initState();
    controller =
        new CameraController(widget.cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  File imageFileLast;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return new Container();
    }
    return Screenshot(
      controller: screenshotController,
      child: Stack(
        fit: StackFit.expand,
        children: [
          new AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: new CameraPreview(controller),
          ),
          GestureDetector(
              child: Center(child: Image.file(imageFile)),
              onTap: () async {
                imageFileLast = null;
                try {
                  imageFileLast =
                      await ImagePicker.pickImage(source: ImageSource.camera)
                          .then((picture) {
                    return picture;
                  });
                } catch (eror) {
                  print('error taking picture}');
                }
                setState(() async => {
                      this.imageFileLast = imageFileLast,
                      makeGetRequestLast(),
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FinishPage()),
                      )
                    });
              })
        ],
      ),
    );
  }

  makeGetRequestLast() async {
    Future.delayed(Duration(seconds: 1));
    imageBytesLast = null;
    imageBytesLast = imageFileLast.readAsBytesSync();
    imgLast = base64Encode(imageBytesLast);
    imageBytes1 = null;
    imageBytes1 = imageFile.readAsBytesSync();
    noBgImgLast = base64Encode(imageBytes1);

    final url = 'http://fb582df11652.ngrok.io/imgLast';

    http.post(url,
        body: json.encode({'imgLast': imgLast, 'noBgImgLast': noBgImgLast}));
  }
}
