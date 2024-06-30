import 'package:flutter/material.dart';
import 'package:realplayadmin/Constraints/constraints.dart';
import 'package:realplayadmin/homepage.dart';
import 'package:typewritertext/typewritertext.dart';

import '../widgets/Bottom_Navigation_Bar.dart';

class Splash_Screen extends StatelessWidget {
  const Splash_Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the user is already authenticated

    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Bottom_Navigation_bar(),
      ));
      // User is not authenticated, navigate to LoginScreen
    });

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Admin Panel",
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
          )
        ],
      )),
    );
  }
}
