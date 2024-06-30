import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:realplayadmin/common/custom_snackbars.dart';
import 'package:realplayadmin/widgets/App_Bar.dart';
import 'package:realplayadmin/widgets/Bottom_Navigation_Bar.dart';

import '../Constraints/constraints.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../common/custom_textfield.dart';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController otherLanguageController = TextEditingController();
  String? imageUrl;
  XFile? pickedImage;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: App_Bar(
          title: "Add Game",
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: backgroundColor, // Change to your desired color
      ),
      backgroundColor: primaryColor, // Change to your desired color
      body:
          // body: Padding(
          //   padding: const EdgeInsets.all(24.0),
          //   child: SingleChildScrollView(
          //     physics: BouncingScrollPhysics(),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         Column(
          //           children: [
          //             GestureDetector(
          //               onTap: () async {
          //                 final picker = ImagePicker();
          //                 XFile? _Image = await picker.pickImage(
          //                   source: ImageSource.gallery,
          //                 );
          //                 if (_Image != null) {
          //                   setState(() {
          //                     pickedImage = _Image;
          //                   });
          //                 }
          //               },
          //               child: Container(
          //                   width: 200,
          //                   height: 200,
          //                   decoration: BoxDecoration(
          //                     color: Colors.white70,
          //                     borderRadius: BorderRadius.circular(100),
          //                   ),
          //                   child: pickedImage != null
          //                       ? ClipRRect(
          //                           borderRadius: BorderRadius.circular(200),
          //                           child: Image(
          //                               fit: BoxFit.cover,
          //                               image: FileImage(File(pickedImage!.path))),
          //                         )
          //                       : const Center(
          //                           child: Column(
          //                           mainAxisAlignment: MainAxisAlignment.center,
          //                           children: [
          //                             Icon(
          //                               Icons.camera_alt,
          //                               size: 40,
          //                               color: Colors.black54,
          //                             ),
          //                             Text(
          //                               'choose a photo',
          //                               style: TextStyle(color: Colors.black54),
          //                             )
          //                           ],
          //                         ))),
          //             ),
          //             const SizedBox(
          //               height: 30,
          //             ),
          //             customTextField(
          //               textController: gameNameController,
          //               hintText: 'Enter Game Name',
          //             ),
          //             const SizedBox(
          //               height: 20,
          //             ),
          //             customTextField(
          //               textController: otherLanguageController,
          //               hintText: 'Enter game name in other language',
          //             ),
          //             const SizedBox(
          //               height: 40,
          //             ),
          //           ],
          //         ),
          //         Spacer(),
          //         SizedBox(
          //             width: double.infinity,
          //             height: 60,
          //             child: ElevatedButton(
          //               onPressed: () async {
          //                 // Validate and save data
          //                 if (gameNameController.text.isEmpty) {
          //                   ScaffoldMessenger.of(context)
          //                       .showSnackBar(const SnackBar(
          //                     content: Text('Please enter game name.'),
          //                   ));
          //                 } else if (otherLanguageController.text.isEmpty) {
          //                   ScaffoldMessenger.of(context)
          //                       .showSnackBar(const SnackBar(
          //                     content: Text('Please enter other language detail.'),
          //                   ));
          //                 } else if (pickedImage == null) {
          //                   ScaffoldMessenger.of(context)
          //                       .showSnackBar(const SnackBar(
          //                     content: Text('Please choose an image.'),
          //                   ));
          //                 } else {
          //                   // upload image to database
          //
          //                   // create firestore database
          //
          //                   await uploadToFirestoreAndSaveData();
          //                 }
          //               },
          //               style: ElevatedButton.styleFrom(
          //                 backgroundColor: backgroundColor,
          //                 shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(10),
          //                 ),
          //               ),
          //               child: isLoading
          //                   ? const SizedBox(
          //                       height: 30,
          //                       width: 30,
          //                       child: CircularProgressIndicator(
          //                         strokeWidth: 3,
          //                         color: Colors.white,
          //                       ))
          //                   : const Text(
          //                       "Add Game",
          //                       style: TextStyle(fontSize: 16, color: Colors.white),
          //                     ),
          //             ))
          //       ],
          //     ),
          //   ),
          // ),

          Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: LayoutBuilder(
          // Use LayoutBuilder to obtain the parent constraints
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: constraints.maxHeight), // Ensure minimum height
                child: IntrinsicHeight(
                  // Use IntrinsicHeight to allow Spacer to work correctly
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              XFile? _Image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (_Image != null) {
                                setState(() {
                                  pickedImage = _Image;
                                });
                              }
                            },
                            child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: backgroundColor, width: 2)),
                                child: pickedImage != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        child: Image(
                                            fit: BoxFit.cover,
                                            image: FileImage(
                                                File(pickedImage!.path))),
                                      )
                                    : const Center(
                                        child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            size: 30,
                                            color: Colors.black54,
                                          ),
                                          Text(
                                            'choose a photo',
                                            style: TextStyle(
                                                color: Colors.black54),
                                          )
                                        ],
                                      ))),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          customTextField(
                            changeBorderColor: true,
                            textController: gameNameController,
                            hintText: 'Enter Game Name',
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          customTextField(
                            changeBorderColor: true,
                            textController: otherLanguageController,
                            hintText: 'Enter game name in other language',
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                      Spacer(), // Now works correctly due to IntrinsicHeight
                      SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Validate and save data
                              if (gameNameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    CustomSnackBars.errorSnackBar(
                                        'Please enter game name.'));
                              } else if (otherLanguageController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    CustomSnackBars.errorSnackBar(
                                        'Please enter other language detail.'));
                              } else if (pickedImage == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(CustomSnackBars.errorSnackBar(
                                  'Please choose an image.',
                                ));
                              } else {
                                // upload image to database

                                await uploadToFirestoreAndSaveData();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ))
                                : const Text(
                                    "Add Game",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> uploadToFirestoreAndSaveData() async {
    // Upload image to Firebase Storage
    try {
      setState(() {
        isLoading = true;
      });
      String imageName = 'game_image_${gameNameController.text.toString()}';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('gameprofile/$imageName');
      UploadTask uploadTask = storageReference.putFile(File(pickedImage!.path));
      await uploadTask.whenComplete(() async {
        // Get image download URL
        imageUrl = await storageReference.getDownloadURL();

        String? docId = await _storeGameData(gameNameController.text.trim(),
            otherLanguageController.text.trim(), imageUrl!);

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBars.successSnackBar("Game Added Successfully."),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Bottom_Navigation_bar()),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBars.errorSnackBar("Something went wrong please try again."),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> _storeGameData(
      String gameName, String otherLanguageName, String gameImage) async {
    try {
      // Reference to the Firestore collection
      CollectionReference games =
          FirebaseFirestore.instance.collection('Games');

      // Add a new document with a specified ID
      DocumentReference documentReference = games.doc(gameName);

      await documentReference.set({
        'GameName': gameName,
        'GameOtherLanguage': otherLanguageName,
        'GameLogo': gameImage
      });

      return documentReference.id;
    } catch (e) {
      print('Error storing data: $e');
    }
  }
}
