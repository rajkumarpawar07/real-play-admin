import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:realplayadmin/homepage.dart';

import 'all_result_screen.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalKey<NavigatorState>(), // Important for unique identification
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
            builder =
                (BuildContext context) => HomePage(); // Your tab's main screen
            break;
          case '/test2':
            builder = (BuildContext context) =>
                TextScreen3(); // Screen to navigate to
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}

class TextScreen2 extends StatelessWidget {
  const TextScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/test2');
            },
            child: Text('tapme')),
        Container(
          height: 100,
          width: 100,
          color: Colors.blue,
        ),
      ],
    );
  }
}

class TextScreen3 extends StatelessWidget {
  const TextScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/');
              },
              child: Text('go to add game')),
          Container(
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}
