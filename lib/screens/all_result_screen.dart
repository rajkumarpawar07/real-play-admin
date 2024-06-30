import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realplayadmin/common/custom_snackbars.dart';
import '../Constraints/constraints.dart';
import '../widgets/App_Bar.dart';
import 'choose_result_of_bid.dart';

class allResultScreen extends StatefulWidget {
  final String gameName;

  const allResultScreen({Key? key, required this.gameName}) : super(key: key);

  @override
  State<allResultScreen> createState() => _EditBaziState();
}

class _EditBaziState extends State<allResultScreen> {
  late DateTime? fromTime;
  late DateTime? toTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: App_Bar(
          title: "Result",
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor, // Replace with your color
      ),
      // bottomNavigationBar: Bottom_Navigation_bar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Text('${widget.gameName}',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 25)),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Games')
                      .doc(widget.gameName)
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

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => chooseReultOfBid(
                                          gameName: widget.gameName,
                                          bidName: baziName,
                                          fromTime: startTime,
                                          toTime: endTime,
                                        )));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.1,
                            decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: Center(
                                child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/banner1.jpg'),
                                      radius: 35.0,
                                    ),
                                    title: Text(
                                      baziName,
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
                                    trailing: const Icon(
                                      Icons.bar_chart,
                                      color: Colors.white,
                                    ))),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                    );
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  bool isResultOpen(String toTime) {
    final now = DateTime.now();
    final toDateTime = convertStringToDateTime(toTime);
    return now.isAfter(toDateTime);
  }

  DateTime convertStringToDateTime(String timeStr) {
    final format = DateFormat('hh:mm a');
    final time = format.parse(timeStr);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  void addCard(String name, DateTime fromtime, DateTime totime) {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(widget.gameName);

    collection.doc(name).set({
      'name': name,
      'fromtime': _formatTime(fromtime),
      'totime': _formatTime(totime),
    });
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
    CollectionReference collection =
        FirebaseFirestore.instance.collection(widget.gameName);

    collection.doc(name).delete();
  }
}
