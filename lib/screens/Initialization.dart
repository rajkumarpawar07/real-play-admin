import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:realplayadmin/Constraints/constraints.dart';
import 'package:realplayadmin/widgets/App_Bar.dart';
import 'package:realplayadmin/widgets/Bottom_Navigation_Bar.dart';

class InitializeApp extends StatefulWidget {
  const InitializeApp({super.key});

  @override
  State<InitializeApp> createState() => _InitializeAppState();
}

class _InitializeAppState extends State<InitializeApp> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController runningTextController = TextEditingController();
  TextEditingController coinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: App_Bar(
          title: "Initialization",
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor,
      ),
      backgroundColor: primaryColor,
      bottomNavigationBar: Bottom_Navigation_bar(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.1,
                child: ElevatedButton(
                  onPressed: () async {
                    bool userConfirmed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Enter Running Text'),
                          content: TextField(
                            controller: runningTextController,
                            decoration:
                                InputDecoration(hintText: 'Enter your text'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // Cancel
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // Confirm
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );

                    // If the user confirmed, update the Firestore document
                    if (userConfirmed == true) {
                      firestore
                          .collection('initializedValues')
                          .doc('Values')
                          .update({
                        'runningText': runningTextController.text,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
                      Text("Text Successfully Updated")));
                      // Clear the controller after updating
                      runningTextController.clear();
                    }
                  },
                  child: Text("Running Text"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.1,
                child: ElevatedButton(
                  onPressed: () async {
                    bool userConfirmed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Coins on SignUp'),
                          content: TextField(
                            controller: coinController,
                            keyboardType: TextInputType.number,
                            decoration:
                                InputDecoration(hintText: 'Enter Coins'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // Cancel
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // Confirm
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );

                    // If the user confirmed, update the Firestore document
                    if (userConfirmed == true) {
                      firestore
                          .collection('initializedValues')
                          .doc('Values')
                          .update({
                        'coins': coinController.text,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
                      Text("Coins Successfully Updated")));
                      // Clear the controller after updating
                      runningTextController.clear();
                    }
                  },
                  child: Text("Coins"),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
