import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:realplayadmin/common/custom_snackbars.dart';
import 'package:realplayadmin/homepage.dart';
import 'package:realplayadmin/widgets/Bottom_Navigation_Bar.dart';
import '../Constraints/constraints.dart';
import '../widgets/App_Bar.dart';
import 'package:intl/intl.dart';

class chooseReultOfBid extends StatefulWidget {
  final String gameName;
  final String bidName;
  final String fromTime;
  final String toTime;

  const chooseReultOfBid(
      {Key? key,
      required this.gameName,
      required this.bidName,
      required this.fromTime,
      required this.toTime})
      : super(key: key);

  @override
  State<chooseReultOfBid> createState() => _EditBaziState();
}

class _EditBaziState extends State<chooseReultOfBid>
    with SingleTickerProviderStateMixin {
  late DateTime? fromTime;
  late DateTime? toTime;

  String winnerNumber = '';
  String winnersCount = '';

  AnimationController? loadingController;

  File? _file;
  PlatformFile? _platformFile;
  String? formattedDate;

  bool _uploadProgress = false;

  selectFile() async {
    final filePicked = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['mp4', 'mkv']);

    if (filePicked != null) {
      setState(() {
        _file = File(filePicked.files.single.path!);
        _platformFile = filePicked.files.first;
      });
    }

    loadingController?.forward();
  }

  late final _contr;
  @override
  void initState() {
    super.initState();
    loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {});
      });
    formattedDate = formatCurrentTimestamp();
    _contr = Get.put(resultController());
  }

  String formatCurrentTimestamp() {
    Timestamp now = Timestamp.now();
    DateTime nowDate = now.toDate();
    final DateFormat formatter = DateFormat('dd MMMM yyyy');
    String formatted = formatter.format(nowDate);
    return formatted;
  }

  @override
  void dispose() {
    loadingController?.dispose(); // Don't forget to dispose of the controller!
    winnerNumber = '';
    _file = null;
    _uploadProgress = false;
    _file = null;
    _platformFile = null;
    _contr.result = ''.obs;
    super.dispose();
  }

  Future<void> uploadVideo(File videoFile, String folderName) async {
    // Reference to the folder
    Reference folderRef = FirebaseStorage.instance.ref().child(folderName);

    try {
      // List all files in the folder
      final ListResult result = await folderRef.listAll();
      // Delete each file in the folder
      for (var fileRef in result.items) {
        await fileRef.delete();
      }
      print('All files in "$folderName" have been deleted.');

      // After deletion, proceed with the file upload
      String filePath =
          '$folderName/${DateTime.now().millisecondsSinceEpoch}_${videoFile.path.split('/').last}';
      Reference fileRef = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = fileRef.putFile(videoFile);

      // Optional: Track the upload progress
      uploadTask.snapshotEvents.listen((event) {
        // setState(() {
        //   _uploadProgress =
        //       event.bytesTransferred / event.totalBytes.toDouble();
        // });
        print('Task state: ${event.state}');
        print(
            'Progress: ${(event.bytesTransferred / event.totalBytes) * 100} %');
      });

      // Wait until the file is uploaded then retrieve download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      if (downloadUrl.isNotEmpty) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentReference videoDocRef =
            firestore.collection('Videos').doc('GameVideos');

        await videoDocRef.update({
          'VideoUrl': downloadUrl,
        }).then((value) {
          // Reset the progress and file references after successful upload

          // Show success message and navigate
          ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBars.successSnackBar('video Updated Successfully!'));
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBars.errorSnackBar(
                  'Failed to Upload, video Please Try again.'));
        });
      }

      print('Upload complete. Download URL: $downloadUrl');
    } catch (e) {
      print(
          'Error occurred while uploading to Firebase Storage or deleting previous files: $e');
    }
  }

  Future<void> updateWinningNumber(String winningNumber) async {
    FirebaseFirestore.instance
        .collection('Games')
        .doc(widget.gameName)
        .collection('Bids')
        .doc(widget.bidName)
        .collection('Date')
        .doc(formattedDate)
        .update({'WinnerNumber': winningNumber})
        .then((_) => print('WinnerNumber updated successfully.'))
        .catchError((error) => print('Error updating WinnerNumber: $error'));
  }

  Future<void> updateBidResultsToUserHistory() async {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    CollectionReference usersCollection = _db.collection('users');

    try {
      // Get all documents in the users collection
      QuerySnapshot querySnapshot = await usersCollection.get();

      // Check if the collection contains any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Loop through all the documents and print their data
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          String phonenumber = userData['phonenumber'] ?? 'No name';

          CollectionReference bidsCollection = _db
              .collection('users')
              .doc(phonenumber)
              .collection('BidHistory')
              .doc(widget.gameName)
              .collection('BidsHistoryInGame');

          try {
            QuerySnapshot querySnapshot = await bidsCollection
                .where('Bid', isEqualTo: widget.bidName.toString())
                .where('Date', isEqualTo: formattedDate)
                .get();

            // Check if documents exist with the specified criteria
            if (querySnapshot.docs.isNotEmpty) {
              // Loop through the documents and update the 'result' field
              for (var doc in querySnapshot.docs) {
                await doc.reference.update({'Result': winnerNumber});
              }
              print('Documents updated successfully.');
            } else {
              print('No matching documents found.');
            }
          } catch (e) {
            print('Error updating documents: $e');
          }
        }
      } else {
        print('No users found.');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> updateResults() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference docForDate = firestore
          .collection('Results')
          .doc(widget.gameName)
          .collection('Date')
          .doc(formattedDate);
      docForDate.set({"Date": formattedDate});

      DocumentReference documentReference = firestore
          .collection('Results')
          .doc(widget.gameName)
          .collection('Date')
          .doc(formattedDate)
          .collection('Bids')
          .doc(widget.bidName);

      Map<String, dynamic> data = {
        'Number': winnerNumber,
        'Winners': winnersCount,
      };

      await documentReference
          .set(data)
          .then((_) => print('Results updated.'))
          .catchError((error) => print('Error updating results: $error'));
    } catch (e) {
      print('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final _controller = Get.put(resultController());
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: App_Bar(
          title: "Result",
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor, // Replace with your color
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.gameName,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 24),
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                tileColor: backgroundColor,
                // Replace with your color
                leading: const CircleAvatar(
                  backgroundColor: Colors.white,
                ),
                title: Text(widget.bidName),
                textColor: Colors.white,
                titleTextStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                subtitle: Text('Timing ${widget.fromTime} - ${widget.toTime}'),
              ),
              const SizedBox(
                height: 30,
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Games')
                    .doc(widget.gameName.toString())
                    .collection('Bids')
                    .doc(widget.bidName.toString())
                    .collection('Date')
                    .doc(formattedDate)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    DocumentReference documentReference = FirebaseFirestore
                        .instance
                        .collection('Games')
                        .doc(widget.gameName.toString())
                        .collection('Bids')
                        .doc(widget.bidName.toString())
                        .collection('Date')
                        .doc(
                            formattedDate); // Ensure 'formattedDate' is defined and formatted correctly

                    // Define the data to be set in the new document
                    Map<String, dynamic> data = {
                      '0': [],
                      '1': [],
                      '2': [],
                      '3': [],
                      '4': [],
                      '5': [],
                      '6': [],
                      '7': [],
                      '8': [],
                      '9': [],
                      'WinnerNumber': ''
                    };

                    // Create the new document with the specified data
                    documentReference
                        .set(data)
                        .then((_) => print("Document successfully created!"))
                        .catchError((error) =>
                            print("Failed to create document: $error"));
                  }
                  Map<String, dynamic>? documentData;

                  try {
                    // Assuming you have? the data
                    documentData =
                        snapshot.data!.data() as Map<String, dynamic>;
                  } catch (e) {}

                  // Use the document data to return a GridView
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 10, // Or dynamically based on the data
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      String numberKey = (index).toString();
                      var fieldValue;
                      try {
                        fieldValue = documentData![numberKey].length.toString();
                      } catch (e) {
                        fieldValue = '0';
                      }
                      String displayValue = fieldValue.toString();

                      int totalCount = 0;

                      try {
                        if (documentData!.containsKey(numberKey)) {
                          List<dynamic> bets = documentData[numberKey];

                          // Iterate through each bet and add the 'count' value
                          for (var bet in bets) {
                            Map<String, dynamic> betData =
                                bet as Map<String, dynamic>;

                            if (betData.containsKey('amount')) {
                              totalCount += betData['amount'] as int;
                            }
                          }
                        }
                      } catch (e) {
                        print(e) {}
                      }

                      return Padding(
                        padding: const EdgeInsets.all(5),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: BouncingWidget(
                            onPressed: () {
                              winnerNumber = (index).toString();
                              _controller.result.value = (index).toString();
                              winnersCount = displayValue;
                            },
                            duration: const Duration(milliseconds: 200),
                            scaleFactor: 2,
                            child: Obx(
                              () => Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: _controller.result.value ==
                                          (index).toString()
                                      ? textColor // Assuming kPrimaryPurple[100]
                                      : backgroundColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Text(
                                          // documentData.keys.elementAt(index), // Key for the field
                                          '${index}',
                                          style: TextStyle(
                                            color: _controller.result.value ==
                                                    (index).toString()
                                                ? Colors.white
                                                : Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'users:$displayValue',
                                          // "${documentData.values.elementAt(index).length}", // Value for the field
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.normal,
                                            color: _controller.result.value ==
                                                    (index).toString()
                                                ? Colors.white
                                                : Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'amount:$totalCount',
                                          // "${documentData.values.elementAt(index).length}", // Value for the field
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.normal,
                                            color: _controller.result.value ==
                                                    (index).toString()
                                                ? Colors.white
                                                : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(
                height: 30,
              ),
              const Text(
                'Select the video',
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Select the mp4 video for winners (Optional)',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: selectFile,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(10),
                      dashPattern: [10, 4],
                      strokeCap: StrokeCap.round,
                      color: Colors.blue.shade600,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                            color: Colors.blue.shade50.withOpacity(.3),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_copy,
                              color: Colors.white38,
                              size: 40,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Select your file',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
              _platformFile != null
                  ? Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected File',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      spreadRadius: 2,
                                    )
                                  ]),
                              child: Row(
                                children: [
                                  // ClipRRect(
                                  //     borderRadius: BorderRadius.circular(8),
                                  //     child: Image.file(
                                  //       _file!,
                                  //       width: 70,
                                  //     )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _platformFile!.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          '${(_platformFile!.size / 1024).ceil()} KB',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade500),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                            height: 5,
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.blue.shade50,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: loadingController?.value,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          ),
                          // MaterialButton(
                          //   minWidth: double.infinity,
                          //   height: 45,
                          //   onPressed: () {},
                          //   color: Colors.black,
                          //   child: Text('Upload', style: TextStyle(color: Colors.white),),
                          // )
                        ],
                      ))
                  : Container(),
              const SizedBox(
                height: 150,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: backgroundColor,
        onPressed: () async {
          print("selcted ${_controller.result.value}");

          if (_controller.result.value.isEmpty || winnerNumber == '') {
            ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackBars.errorSnackBar('Please choose a number.'));
          } else if (_file == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackBars.errorSnackBar('Please select the video.'));
          } else {
            await performAllTasks(_controller);
          }
        },
        isExtended: true,
        label: _uploadProgress
            ? SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                "Upload result",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> performAllTasks(resultController _controller) async {
    setState(() {
      _uploadProgress = true;
    });
    print('performing all tasks');
    print(_controller.result.value.toString());
    await updateWinningNumber(_controller.result.value.toString());

    if (_file != null) {
      await uploadVideo(_file!, "Videos");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBars.errorSnackBar('Please select the video.'));
    }
    // -- update user's history
    await updateBidResultsToUserHistory();

    // -- update results
    await updateResults();

    // Show success message and navigate
    ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBars.successSnackBar('Result Updated Successfully!'));
    setState(() {
      _uploadProgress = false;
      _file = null;
      _platformFile = null;
    });
    Navigator.pop(context);
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

class resultController extends GetxController {
  Rx<String> result = ''.obs;
}
