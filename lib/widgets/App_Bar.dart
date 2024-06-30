import 'package:flutter/material.dart';

class App_Bar extends StatelessWidget {
  String title;
  App_Bar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}
