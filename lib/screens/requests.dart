import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:realplayadmin/screens/add_money_request_screen.dart';
import 'package:realplayadmin/screens/withdraw_request_screen.dart';
import 'package:realplayadmin/widgets/App_Bar.dart';

import '../Constraints/constraints.dart';

class RequestList extends StatefulWidget {
  const RequestList({super.key});

  @override
  State<RequestList> createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalKey<NavigatorState>(), // Important for unique identification
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
            builder = (BuildContext context) =>
                const Request(); // Your tab's main screen
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}

class Request extends StatelessWidget {
  const Request({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: App_Bar(
          title: "Requests",
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor, // Change to your desired color
      ),
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () => Get.to(() => AddMoneyRequestScreen()),
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Center(
                    child: Text(
                  'Add Money Requests',
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () => Get.to(() => WithdrawMoneyRequest()),
              child: Container(
                height: 80,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Center(
                    child: Text(
                  'Withdraw Money Requests',
                  style: TextStyle(color: Colors.white),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
