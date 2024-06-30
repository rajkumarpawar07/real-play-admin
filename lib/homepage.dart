import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:realplayadmin/Constraints/constraints.dart';
import 'package:realplayadmin/common/custom_snackbars.dart';
import 'package:realplayadmin/screens/Initialization.dart';
import 'package:realplayadmin/screens/add_bid_screen.dart';
import 'package:realplayadmin/widgets/App_Bar.dart';
import 'package:realplayadmin/widgets/Bottom_Navigation_Bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  VideoPlayerController? _controller;
  String nextGameTime = '';

  @override
  void initState() {
    super.initState();
    getVideo();
    getTime();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // This function fetches the video URL and initializes the video player
  Future<void> getVideo() async {
    try {
      // Fetch the document
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Videos')
          .doc('GameVideos')
          .get();

      // Extract the videoUrl from the document
      if (documentSnapshot.exists) {
        final videoUrl = documentSnapshot.get('VideoUrl');

        FileInfo? fileInfo =
            await DefaultCacheManager().getFileFromCache(videoUrl);

        if (fileInfo == null) {
          await DefaultCacheManager().downloadFile(videoUrl).then((fileInfo) {
            _initializeVideoPlayer(fileInfo.file.path);
          });
        } else {
          _initializeVideoPlayer(fileInfo.file.path);
        }
      }
    } catch (e) {
      print('Error fetching video: $e');
    }
  }

  void _initializeVideoPlayer(String filePath) {
    _controller = VideoPlayerController.file(File(filePath))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller?.setVolume(0);
          _controller?.play(); // Automatically play the video
          _controller?.setLooping(true);
        }
      });
  }

  DateTime getNext90MinutesSlot(DateTime currentTime, DateTime baseTime) {
    // Calculate difference in minutes from base time
    int minutesSinceBase = currentTime.difference(baseTime).inMinutes;

    // Calculate how many slots of 90 minutes have passed
    int slotsPassed = (minutesSinceBase / 30).ceil();

    // Calculate the next slot time
    return baseTime.add(Duration(minutes: slotsPassed * 30));
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  void getTime() {
    DateTime currentTime = DateTime.now(); // Year, Month, Day, Hour, Minute
    DateTime baseTime =
        DateTime(currentTime.year, currentTime.month, currentTime.day, 0, 0);

    // Find the next slot 90 minutes after 12:00 AM considering the current time
    DateTime nextSlot = getNext90MinutesSlot(currentTime, baseTime);

    // Format and print the next slot time
    nextGameTime = formatDateTime(nextSlot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Admin Panel",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor, // Replace with your color
      ),
      backgroundColor: primaryColor,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.03,
            color: Colors.black,
            child: Center(
              child: Marquee(
                text:
                    'Next game starts at $nextGameTime. अगला गेम शुरू होता है $nextGameTime बजे.',
                style: TextStyle(color: Colors.white),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                blankSpace: 10.0,
                velocity: 50.0,
                startPadding: 10.0,
                accelerationCurve: Curves.linear,
              ),
            ),
          ),
          Expanded(
            child: _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!))
                : const Center(
                    child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.04,
              color: backgroundColor,
              child: const Text(
                "   Edit Games",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Games').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Loading indicator while fetching data
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
                      var gameId = snapshot.data?.docs[index].id;
                      var gameName = game?['GameName'];
                      var otherLanguageName = game?['GameOtherLanguage'];
                      var gameImage = game?['GameLogo'];

                      return Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 1.0),
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
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                                subtitle: Text(
                                  gameName ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddBidScreen(
                                                      gameId: gameName!),
                                            ),
                                          );
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
                                      SizedBox(width: 10),
                                      // Adjust the spacing between icons
                                      GestureDetector(
                                          onTap: () async {
                                            bool? confirmDelete =
                                                await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  titlePadding:
                                                      const EdgeInsets.all(0),
                                                  contentPadding:
                                                      const EdgeInsets.all(20),
                                                  backgroundColor: Colors.white,
                                                  title: const Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        'Confirm Delete?',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 24,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                  content: RichText(
                                                    textAlign: TextAlign.center,
                                                    text: TextSpan(
                                                      children: [
                                                        const TextSpan(
                                                          text:
                                                              'Are you sure you want to delete ',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        TextSpan(
                                                            text: '$gameName',
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors
                                                                    .red)),
                                                        const TextSpan(
                                                            text: " game.",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Colors
                                                                    .black)),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        OutlinedButton(
                                                          style: ButtonStyle(
                                                            shape: MaterialStateProperty.all(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0))),
                                                            side: MaterialStateProperty
                                                                .all(
                                                                    const BorderSide(
                                                              color: Colors
                                                                  .black54,
                                                            )),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(
                                                                    false); // Cancel deletion
                                                          },
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .black,
                                                                size: 20,
                                                              ),
                                                              Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
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
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                        .red),
                                                            shape: MaterialStateProperty.all(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0))),
                                                            side: MaterialStateProperty
                                                                .all(
                                                                    const BorderSide(
                                                              color: Colors.red,
                                                            )),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(
                                                                    true); // Confirm deletion
                                                          },
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .white,
                                                                size: 20,
                                                              ),
                                                              Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
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

                                            if (confirmDelete == true) {
                                              try {
                                                print('deleted');
                                                await FirebaseFirestore.instance
                                                    .collection('Games')
                                                    .doc(gameName)
                                                    .delete();

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  CustomSnackBars.successSnackBar(
                                                      '$gameName deleted successfully!'),
                                                );
                                              } catch (e) {
                                                print(
                                                    'Error deleting item: $e');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  CustomSnackBars.errorSnackBar(
                                                      'Failed to delete $gameName'),
                                                );
                                              }
                                            }
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
                                    ]),
                              ),
                            ),
                          ));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
