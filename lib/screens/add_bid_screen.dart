import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Constraints/constraints.dart';
import '../common/custom_snackbars.dart';
import '../common/custom_textfield.dart';

class AddBidScreen extends StatefulWidget {
  final String gameId;

  const AddBidScreen({Key? key, required this.gameId}) : super(key: key);

  @override
  State<AddBidScreen> createState() => _AddBidScreenState();
}

class _AddBidScreenState extends State<AddBidScreen> {
  late DateTime? fromTime;
  late DateTime? toTime;
  String endTime = '';
  String startTime = '';
  String name = '';
  String editedName = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text(
          "Add Bid",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor, // Replace with your color
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            const Text(
              'All available bids',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Games')
                      .doc(widget.gameId)
                      .collection('Bids')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    // Format the timestamp for display
                    final dateFormat = DateFormat('hh:mm a');

                    return ListView.separated(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        var bazi = snapshot.data?.docs[index].data()
                            as Map<String, dynamic>;

                        var baziName = bazi['BidName'] as String? ?? 'Unknown';
                        var startTime = bazi['start'];
                        var endTime = bazi['end'];

                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                              child: ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage('assets/banner1.jpg'),
                              radius: 35.0,
                            ),
                            title: Text(
                              baziName ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            subtitle: Text(
                              'Time: $startTime - $endTime',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showEditDialog(baziName);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                GestureDetector(
                                    onTap: () {
                                      deleteCard(baziName);
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ))
                              ],
                            ),
                          )),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 10,
                        );
                      },
                    );
                  }),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  _showInputDialog();
                },
                child: Text(
                  "Add Bid",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor, // Replace with your color
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String editedName) async {
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController =
            TextEditingController(text: editedName);
        return AlertDialog(
          title: const Text('Edit Bid Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              customTextField(
                  textController: nameController,
                  changeBorderColor: true,
                  hintText: "Name"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (picked != null) {
                          final localizations =
                              MaterialLocalizations.of(context);

                          String formattedTime = localizations.formatTimeOfDay(
                              picked,
                              alwaysUse24HourFormat: false);

                          print(formattedTime);
                          startTime = formattedTime;
                        }
                      },
                      child: const Text(
                        'Start',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (picked != null) {
                          final localizations =
                              MaterialLocalizations.of(context);

                          String formattedTime = localizations.formatTimeOfDay(
                              picked,
                              alwaysUse24HourFormat: false);

                          endTime = formattedTime;
                        }
                      },
                      child: Text(
                        'End',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBars.errorSnackBar('Enter Bid Name.'));
                } else if (startTime!.isEmpty || startTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBars.errorSnackBar('Enter valid start time.'));
                } else if (endTime.isEmpty || endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBars.errorSnackBar('Enter valid end time.'));
                } else {
                  print(startTime);
                  print(endTime);
                  print(nameController.text);
                  print(editedName);

                  // Add bid to game
                  await editBidToGame(widget.gameId, editedName,
                      nameController.text, startTime, endTime);

                  startTime = '';
                  endTime = '';
                  name = '';
                }

                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showInputDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Bid Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              customTextField(
                  changeBorderColor: true,
                  onChange: (value) {
                    name = value;
                  },
                  hintText: "Name"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (picked != null) {
                          final localizations =
                              MaterialLocalizations.of(context);

                          String formattedTime = localizations.formatTimeOfDay(
                              picked,
                              alwaysUse24HourFormat: false);

                          print(formattedTime);
                          startTime = formattedTime;
                        }
                      },
                      child: const Text(
                        'Start',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (picked != null) {
                          final localizations =
                              MaterialLocalizations.of(context);

                          String formattedTime = localizations.formatTimeOfDay(
                              picked,
                              alwaysUse24HourFormat: false);

                          endTime = formattedTime;
                        }
                      },
                      child: Text(
                        'End',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBars.errorSnackBar('Enter Bid Name.'));
                } else if (startTime!.isEmpty || startTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBars.errorSnackBar('Enter valid start time.'));
                } else if (endTime.isEmpty || endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBars.errorSnackBar('Enter valid end time.'));
                } else {
                  print(startTime);
                  print(endTime);
                  print(name);

                  // Add bid to game
                  await addBidToGame(widget.gameId, name, startTime, endTime);

                  startTime = '';
                  endTime = '';
                  name = '';
                }

                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  String formattedDateTime(DateTime fromTime) {
    final DateFormat formatter =
        DateFormat("d MMMM yyyy 'at' HH:mm:ss 'UTC+5:30'");
    final String formatted = formatter.format(fromTime);
    return formatted;
  }

  Future<void> editBidToGame(
    String gameName,
    String oldBidName,
    String newBidName,
    String startTime,
    String endTime,
  ) async {
    print('edit game method');

    print('gameName: $gameName');
    print('oldBidName: $oldBidName');
    print('newBidName: $newBidName');
    print('startTime: $startTime');
    print('endTime: $endTime');

    try {
      CollectionReference games =
          FirebaseFirestore.instance.collection('Games');

      DocumentReference gameDocumentRef = games.doc(gameName);

      CollectionReference gameSubcollection =
          gameDocumentRef.collection('Bids');

      DocumentReference oldBidReference = gameSubcollection.doc(oldBidName);

      // Get the data from the old document
      DocumentSnapshot oldBidSnapshot = await oldBidReference.get();
      Map<String, dynamic>? oldData =
          oldBidSnapshot.data() as Map<String, dynamic>?;

      if (oldData != null) {
        // Create a new document with the new bid name and the old data
        DocumentReference newBidReference = gameSubcollection.doc(newBidName);
        await newBidReference.set({
          ...oldData,
          'BidName': newBidName,
          'start': startTime,
          'end': endTime,
        });

        // Delete the old document
        // await oldBidReference.delete();
      } else {
        print('No data found in the document');
      }
    } catch (e) {
      print('error $e');
    }
  }

  Future<void> addBidToGame(
    String gameName,
    String bidName,
    String startTime,
    String endTime,
  ) async {
    try {
      CollectionReference games =
          FirebaseFirestore.instance.collection('Games');

      DocumentReference gameDocumentRef = games.doc(gameName);

      CollectionReference gameSubcollection =
          gameDocumentRef.collection('Bids');

      DocumentReference bidReference = gameSubcollection.doc(bidName);

      await bidReference.set({
        'BidName': bidName,
        'start': startTime,
        'end': endTime,
      });
    } catch (e) {
      print('error $e');
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return 'N/A';
    }
    String period = time.hour < 12 ? 'am' : 'pm';
    int hour = time.hour == 0 ? 12 : time.hour;
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute$period';
  }

  void deleteCard(String name) {
    print('delete game');
    CollectionReference games = FirebaseFirestore.instance.collection('Games');

    DocumentReference gameDocumentRef = games.doc(widget.gameId);

    CollectionReference gameSubcollection = gameDocumentRef.collection('Bids');

    DocumentReference bidReference = gameSubcollection.doc(name);

    bidReference.delete();
  }
}
