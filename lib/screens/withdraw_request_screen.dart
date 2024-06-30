import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Constraints/constraints.dart';
import '../common/custom_snackbars.dart';
import '../widgets/App_Bar.dart';

class WithdrawMoneyRequest extends StatefulWidget {
  const WithdrawMoneyRequest({super.key});

  @override
  State<WithdrawMoneyRequest> createState() => _WithdrawMoneyRequestState();
}

class _WithdrawMoneyRequestState extends State<WithdrawMoneyRequest>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the TabController to free up resources
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: App_Bar(
          title: 'Withdraw Requests',
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor,
        bottom: TabBar(
          indicatorColor: Colors.white,
          dividerColor: Colors.white,
          controller: _tabController, // Use the explicitly created controller
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              text: 'Requests',
            ),
            Tab(text: 'History'),
          ],
        ),
      ),
      backgroundColor: primaryColor,
      body: TabBarView(
        controller: _tabController, // Use the same controller here
        children: const [
          WithdrawRequests(),
          WithdrawRequestsHistory(),
        ],
      ),
    );
  }
}

/// ->>>>>>>>>>>>>>>>>> withdraw requests
class WithdrawRequests extends StatefulWidget {
  const WithdrawRequests({super.key});

  @override
  State<WithdrawRequests> createState() => _WithdrawRequestsState();
}

class _WithdrawRequestsState extends State<WithdrawRequests> {
  Future<void> removeCoins(int coinsToSub, String userPhoneNumber) async {
    // Reference to Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Document reference for the user
    DocumentReference userDoc =
        firestore.collection('users').doc(userPhoneNumber);

    try {
      // Run a transaction to ensure atomic read and write
      await firestore.runTransaction((transaction) async {
        // Get the user's document
        DocumentSnapshot userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          throw Exception("User does not exist!");
        }

        // Get the current number of coins
        int currentCoins = userSnapshot['coins'] ?? 0;

        // Calculate the new total
        int newTotal = currentCoins - coinsToSub;

        // Update the user's document with the new coin total
        transaction.update(userDoc, {'coins': newTotal});
      });

      print("Coins added successfully.");
    } catch (e) {
      print("Failed to add coins: $e");
      // Optionally, handle the error e.g., show a user-friendly message
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('WithdrawMoney')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Text('No Data Available');
              }

              List<QueryDocumentSnapshot> filteredDocs =
                  snapshot.data!.docs.where((doc) {
                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                return data['Status'] == 'Pending';
              }).toList();

              if (filteredDocs.isEmpty) {
                return const Center(
                  child: Text(
                    'No Pending Requests',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot docSnapshot = filteredDocs[index];
                  Map<String, dynamic> data =
                      docSnapshot.data()! as Map<String, dynamic>;

                  return Card(
                    color:
                        backgroundColor, // Assuming a dark theme, adjust the color as needed
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Name : ${data['Name']}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          textColor),
                                ),
                                onPressed: () async {
                                  bool? confirmApprove = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        titlePadding: const EdgeInsets.all(0),
                                        contentPadding:
                                            const EdgeInsets.all(20),
                                        backgroundColor: Colors.white,
                                        title: const Column(
                                          children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              'APPROVE WITHDRAW REQUEST?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        content: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text:
                                                    'Are you sure you want to approve ',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.black),
                                              ),
                                              TextSpan(
                                                  text:
                                                      '₹${data['Amount'].toString()}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.red)),
                                              const TextSpan(
                                                  text: " of ",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black)),
                                              TextSpan(
                                                  text: '${data['Name']}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              OutlinedButton(
                                                style: ButtonStyle(
                                                  shape: MaterialStateProperty
                                                      .all(RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0))),
                                                  side:
                                                      MaterialStateProperty.all(
                                                          const BorderSide(
                                                    color: Colors.black54,
                                                  )),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      false); // Cancel deletion
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.close,
                                                      color: Colors.black,
                                                      size: 20,
                                                    ),
                                                    Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.green),
                                                  shape: MaterialStateProperty
                                                      .all(RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0))),
                                                  side:
                                                      MaterialStateProperty.all(
                                                          const BorderSide(
                                                    color: Colors.green,
                                                  )),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      true); // Confirm deletion
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    Text(
                                                      'Approve',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirmApprove == true) {
                                    try {
                                      print('Approved');

                                      /// TODO approve that documents data['status'] to 'approved'
                                      await docSnapshot.reference
                                          .update({'Status': 'Approved'});
                                      print('Request approved successfully');

                                      await removeCoins(
                                          int.parse(data['Amount']),
                                          data['UserNumber'].toString());
                                    } catch (e) {
                                      print('Error Approving amount: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        CustomSnackBars.errorSnackBar(
                                            'Failed to approve, Please try again.'),
                                      );
                                    }
                                  }
                                },
                                child: Text(
                                  data['Status'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.phone_android, color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                data['UserNumber'].toString(),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                '₹${data['Amount'].toString()}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.payment, color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                " ${data['PaymentType']} - ${data['PhoneNumber'].toString()}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class WithdrawRequestsHistory extends StatefulWidget {
  const WithdrawRequestsHistory({super.key});

  @override
  State<WithdrawRequestsHistory> createState() =>
      _WithdrawRequestsHistoryState();
}

class _WithdrawRequestsHistoryState extends State<WithdrawRequestsHistory> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('WithdrawMoney')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Text('No Data Available');
              }

              List<QueryDocumentSnapshot> filteredDocs =
                  snapshot.data!.docs.where((doc) {
                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                return data['Status'] != 'Pending';
              }).toList();

              if (filteredDocs.isEmpty) {
                return const Center(
                  child: Text(
                    'No Pending Requests',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot docSnapshot = filteredDocs[index];
                  Map<String, dynamic> data =
                      docSnapshot.data()! as Map<String, dynamic>;

                  return Card(
                    color:
                        backgroundColor, // Assuming a dark theme, adjust the color as needed
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Name : ${data['Name']}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                ),
                                onPressed: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      CustomSnackBars.infoSnackBar(
                                          'Already Approved'));
                                },
                                child: Text(
                                  data['Status'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.phone_android,
                                  color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                data['UserNumber'].toString(),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                '₹${data['Amount'].toString()}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.payment, color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                " ${data['PaymentType']} - ${data['PhoneNumber'].toString()}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
