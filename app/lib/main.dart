import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:removeBgAndPasteComputer/camera.dart';
import 'package:removeBgAndPasteComputer/splashscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as imageLib;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MaterialApp(
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  MyPage({this.cameras});
  @override
  _MyPageState createState() => _MyPageState();
}

File imageFile;

String encodedString;
String filePath;
File fileEdit;
Uint8List noBgImg;
PickedFile pickedFile;
List<int> imageBytes;

class _MyPageState extends State<MyPage> {
  String photoBase64 = "";
  String encoded_string = "";
  String finalresponse = "";
  String fileName;
  List<Filter> filters = presetFiltersList;

  Future getImage(context) async {
    fileName = basename(fileEdit.path);
    var image = imageLib.decodeImage(fileEdit.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
    Map imagefile = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new PhotoFilterSelector(
            title: Text("Photo Filter"),
            image: image,
            filters: presetFiltersList,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
            filename: fileName,
            appBarColor: Color.fromRGBO(151, 189, 223, 1),
          ),
        ));
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CameraScreen(cameras)),
        );
      });
      print(imageFile.path);
    }
  }

  Future<String> getFilePath() async {
    Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    filePath = '$appDocumentsPath/myimage.png'; // 3

    return filePath;
  }

  void saveFile() async {
    fileEdit = File(await getFilePath());
    fileEdit.writeAsBytesSync(noBgImg);
  }

  Widget build(BuildContext context) {
    return Container(
        color: Color.fromRGBO(151, 189, 223, 1),
        child: imageFile == null
            ? Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Text(
                        "Remove Background \n       And \nPaste On Computer",
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 18,
                            fontStyle: FontStyle.normal,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 400,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 120,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0))),
                                onPressed: () {
                                  imageFile = null;
                                  encodedString = null;
                                  fileEdit = null;
                                  _getFromCamera();
                                },
                                child: Text(
                                  "CAMERA",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(151, 189, 223, 1)),
                                )),
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          SizedBox(
                            height: 50,
                            width: 120,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                              ),
                              onPressed: () {
                                imageFile = null;
                                encodedString = null;
                                fileEdit = null;
                                _getFromGallery();
                              },
                              child: Text(
                                "GALLERY",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(151, 189, 223, 1)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : FutureBuilder(
                future: makeGetRequest(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      margin: EdgeInsets.only(top: 40),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Flexible(flex: 3, child: Image.memory(noBgImg)),
                          SizedBox(
                            height: 80,
                          ),
                          Flexible(
                            flex: 1,
                            child: SizedBox(
                              height: 50,
                              width: 120,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                ),
                                onPressed: () {
                                  getImage(context);
                                },
                                child: Text(
                                  "Edit",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(151, 189, 223, 1)),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }));
  }

  _getFromGallery() async {
    pickedFile = null;
    pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = null;
        imageFile = File(pickedFile.path);

        imageBytes = null;
        imageBytes = imageFile.readAsBytesSync();
        photoBase64 = base64Encode(imageBytes);

        final url = 'http://fb582df11652.ngrok.io/photoBase64';
        final response =
            http.post(url, body: json.encode({'photoBase64': photoBase64}));
        var timer = new Timer(Duration(seconds: 5), null);
        makeGetRequest();
      });
    }
  }

  makeGetRequest() async {
    final url = 'http://fb582df11652.ngrok.io/photoBase64';

    http.Response response = await http.get(url);

    String json = response.body;
    Map<String, dynamic> map = jsonDecode(json);
    encodedString = null;
    encodedString = map['encoded_string'];
    noBgImg = null;
    noBgImg =
        base64Decode(encodedString.substring(2, encodedString.length - 1));
    getFilePath();
    saveFile();
  }

  _getFromCamera() async {
    pickedFile = null;
    pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = null;
        imageFile = File(pickedFile.path);

        List<int> imageBytes = imageFile.readAsBytesSync();
        photoBase64 = base64Encode(imageBytes);

        final url = 'http://fb582df11652.ngrok.io/photoBase64';

        final response =
            http.post(url, body: json.encode({'photoBase64': photoBase64}));
        var timer = new Timer(Duration(seconds: 5), null);
        makeGetRequest();
      });
    }
  }
}

class GetImageFile {
  GetImageFile(this.encoded_string);
  final String encoded_string;
}
