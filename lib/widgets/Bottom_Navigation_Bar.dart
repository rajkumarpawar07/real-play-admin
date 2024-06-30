import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realplayadmin/Constraints/constraints.dart'; // Ensure this file exists and contains textColor definition
import 'package:realplayadmin/homepage.dart'; // Ensure this file exists
import 'package:realplayadmin/screens/add_game_screen.dart'; // Ensure this file exists
import 'package:realplayadmin/screens/results.dart'; // Ensure this file exists
import 'package:realplayadmin/screens/testScreen.dart';
import 'package:realplayadmin/screens/users.dart';

import '../screens/add_bid_screen.dart';
import '../screens/bottom_navigation_screens/home_screens_list.dart';
import '../screens/bottom_navigation_screens/result_screens_list.dart';
import '../screens/requests.dart'; // Ensure this file exists

class Bottom_Navigation_bar extends StatefulWidget {
  @override
  State<Bottom_Navigation_bar> createState() => _Bottom_Navigation_barState();
}

class _Bottom_Navigation_barState extends State<Bottom_Navigation_bar> {
  int _currentIndex = 0;
  final List<Widget> pages = [
    HomeScreensList(),
    AddGameScreen(),
    ResultScreensLists(),
    RequestList(),
    UserScreen(),
  ];

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,

        backgroundColor: backgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: backgroundColor,
          ),
          BottomNavigationBarItem(
              backgroundColor: backgroundColor,
              icon: Icon(Icons.add, size: 30),
              label: "Add Game"),
          BottomNavigationBarItem(
              backgroundColor: backgroundColor,
              icon: Icon(Icons.bar_chart),
              label: "Result"),
          BottomNavigationBarItem(
              backgroundColor: backgroundColor,
              icon: Icon(Icons.request_page),
              label: "Request"),
          BottomNavigationBarItem(
              backgroundColor: backgroundColor,
              icon: Icon(Icons.supervised_user_circle_sharp),
              label: "Users"),
        ],
        // selectedItemColor: textColor, // Ensure this is defined
        // unselectedItemColor: backgroundColor,
        currentIndex: _currentIndex,
        onTap: _changePage,
      ),
    );
  }
}
