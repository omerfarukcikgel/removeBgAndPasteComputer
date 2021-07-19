import 'package:flutter/material.dart';
import 'package:removeBgAndPasteComputer/main.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: MyPage(),
      duration: 6000,
      imageSize: 200,
      imageSrc: "sdu-logo.png",
      text: "Remove Background \n And \n Paste On Computer",
      textType: TextType.TyperAnimatedText,
      textStyle: TextStyle(
        fontSize: 21.0,
        color: Colors.white,
      ),
      backgroundColor: Color.fromRGBO(151, 189, 223, 1),
    );
  }
}
