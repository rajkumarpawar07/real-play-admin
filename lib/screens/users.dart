import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:realplayadmin/Constraints/constraints.dart';
import 'package:realplayadmin/screens/usersinfo.dart';
import 'package:realplayadmin/widgets/App_Bar.dart';
import 'package:realplayadmin/widgets/Bottom_Navigation_Bar.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String profilepic;
  final String coins;
  final String wincounts;
  final String losscounts;
  final String bankname;
  final String accountnumber;
  final String ifsccode;
  final String paytm;
  final String googlepay;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.profilepic,
    required this.coins,
    required this.wincounts,
    required this.losscounts,
    required this.bankname,
    required this.accountnumber,
    required this.ifsccode,
    required this.paytm,
    required this.googlepay,
  });

  factory User.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return User(
      id: snapshot.id,
      name: data['name'] ?? '',
      phone: data['phonenumber'] ?? '',
      profilepic: data['profilepic'] ?? '',
      bankname: data['bankname'] ?? '',
      accountnumber: data['accountnumber'] ?? '',
      ifsccode: data['ifsccode'] ?? '',
      paytm: data['paytm'] ?? '',
      googlepay: data['googlepay'] ?? '',
      coins: data['coins'].toString() ?? '',
      losscounts: data['losscounts'] ?? '',
      wincounts: data['wincounts'] ?? '',
    );
  }
}

class UserScreen extends StatefulWidget {
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>> data =
      FirebaseFirestore.instance.collection('users').snapshots();

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTotalUserCount();
  }

  var totalCount;

  Future<void> getTotalUserCount() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      totalCount = snapshot.size;
    });
  }

  // Function to filter users based on search query
  List<User> filterUsers(List<User> allUsers, String searchQuery) {
    return allUsers
        .where((user) =>
            user.phone.contains(searchQuery) || user.name.contains(searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor,
      ),
      backgroundColor: primaryColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, spreadRadius: 1, blurRadius: 5)
                  ]),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search User',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Total User : ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 15),
              Text(
                '$totalCount',
                style: TextStyle(
                  color: backgroundColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: data,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                List<User> allUsers = snapshot.data!.docs
                    .map((doc) => User.fromDocumentSnapshot(doc))
                    .toList();

                List<User> filteredUsers = filterUsers(
                  allUsers,
                  searchController.text,
                );

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 1,
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                filteredUsers[index].profilepic,
                              ),
                              radius: 35,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    filteredUsers[index].name,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    filteredUsers[index].phone,
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserInfo(
                                      phonenumber: filteredUsers[index].phone,
                                      name: filteredUsers[index].name,
                                      profilepic:
                                          filteredUsers[index].profilepic,
                                      bankname: filteredUsers[index].bankname,
                                      accountnumber:
                                          filteredUsers[index].accountnumber,
                                      paytm: filteredUsers[index].paytm,
                                      googlepay: filteredUsers[index].googlepay,
                                      ifsccode: filteredUsers[index].ifsccode,
                                      coins: filteredUsers[index].coins,
                                      losscounts:
                                          filteredUsers[index].losscounts,
                                      wincounts: filteredUsers[index].wincounts,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                              ),
                              child: Center(
                                  child: Icon(
                                Icons.arrow_forward_ios,
                                color: backgroundColor,
                              )),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
