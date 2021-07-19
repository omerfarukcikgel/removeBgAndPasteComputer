import 'package:flutter/material.dart';

class FinishPage extends StatefulWidget {
  const FinishPage({Key key}) : super(key: key);

  @override
  _FinishPageState createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(151, 189, 223, 1),
      child: Center(
          child: Icon(
        Icons.done,
        size: 100,
        color: Colors.white,
      )),
    );
  }
}
