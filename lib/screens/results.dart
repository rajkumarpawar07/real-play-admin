import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:realplayadmin/Constraints/constraints.dart';
import 'package:realplayadmin/widgets/App_Bar.dart';
import 'package:realplayadmin/widgets/Bottom_Navigation_Bar.dart';

import 'all_result_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: App_Bar(
          title: 'Result',
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor,
      ),
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            // const Text(
            //   "Declare Results",
            //   style: TextStyle(
            //       color: Colors.white,
            //       fontWeight: FontWeight.bold,
            //       fontSize: 25),
            // ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Games').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ); // Loading indicator while fetching data
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  // Use ListView.builder to display data from Firestore
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        var game = snapshot.data?.docs[index];
                        var gameName = game?['GameName'];
                        var otherLanguageName = game?['GameOtherLanguage'];
                        var gameImage = game?['GameLogo'];

                        return Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 1.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => allResultScreen(
                                            gameName: gameName,
                                          )));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.09,
                              decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Center(
                                child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(gameImage),
                                    ),
                                    title: Text(
                                      otherLanguageName ?? '',
                                      style: TextStyle(
                                          color: Colors.grey.shade500),
                                    ),
                                    subtitle: Text(
                                      gameName ?? '',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: const Icon(
                                      Icons.bar_chart,
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Results extends StatefulWidget {
  final String gameName;

  const Results({super.key, required this.gameName});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  int baziCount = 0;

  List<Map<dynamic, dynamic>> results = [];

  void getBaziCount() {
    FirebaseFirestore.instance
        .collection('${widget.gameName}')
        .get()
        .then((value) {
      setState(() {
        baziCount = value.docs.length;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getBaziCount();
    getresults();
  }

  void getresults() {
    // FirebaseFirestore.instance
    //     .collectionGroup(
    //         '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}')
    //     .get()
    //     .then((value) {
    //   setState(() {
    //     results = value.docs
    //         .map((doc) => doc.data() as Map<String, dynamic>)
    //         .toList();
    //   });
    // });
    FirebaseFirestore.instance.collection('results').get().then((value) {
      setState(() {
        results = value.docs
            .map((doc) => doc.data() as Map<dynamic, dynamic>)
            .toList();
      });
    });
  }

  void showRadioDialog(int index) {
    int selectedValue = 1; // Default selected value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a value"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(9, (i) {
                  return RadioListTile<int>(
                    title: Text((i + 1).toString()),
                    value: i + 1,
                    groupValue: selectedValue,
                    onChanged: (int? value) {
                      setState(() {
                        selectedValue = value!;
                      });
                    },
                  );
                }),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Store the selected value in Firebase
                storeSelectedValue(index, selectedValue);

                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void storeSelectedValue(int index, int selectedValue) {
    DateTime now = DateTime.now();
    // Perform Firebase data storage here using the index and selectedValue
    FirebaseFirestore.instance
        .collection('${widget.gameName}')
        .doc(
            '${now.day}-${now.month}-${now.year}') // Provide a unique identifier for each document
        .update({'Bazi ${index}': selectedValue});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: App_Bar(
          title: "All Resuls",
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor,
      ),
      bottomNavigationBar: Bottom_Navigation_bar(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: primaryColor,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  Map<dynamic, dynamic> resultData = results[index];

                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.13,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Display your results here
                          Text(
                            resultData['Date'].toString(),
                            // Replace 'Bazi 1' with the actual key
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black),
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: baziCount,
                              itemBuilder: (context, index1) {
                                return Padding(
                                  padding: const EdgeInsets.all(7.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      showRadioDialog(index1 + 1);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.09,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          resultData['Bazi ${index1 + 1}']
                                              .toString(),
                                          // Adjust the key based on your data structure
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  onPressed: () {
                    // Replace 'yourGameName' with the actual game name
                    String gameName = widget.gameName;

                    // Replace 'yourBaziCount' with the actual count of bazis
                    // int baziCount = 5; // For example, change this to the actual count

                    Map<String, dynamic> baziData = {};
                    baziData['Date'] =
                        '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}';
                    baziData['gameName'] = '${widget.gameName}';
                    for (int i = 1; i <= baziCount; i++) {
                      // Generate the key, e.g., 'Bazi 1', 'Bazi 2', ...
                      String baziKey = 'Bazi $i';

                      // Set the initial value to '-'
                      baziData[baziKey] = '-';
                    }

                    // Add the data to Firestore
                    FirebaseFirestore.instance
                        .collection('results')
                        .doc(gameName)
                        .collection(
                            '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().month}')
                        .add(baziData);
                  },
                  child: Icon(Icons.add),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
