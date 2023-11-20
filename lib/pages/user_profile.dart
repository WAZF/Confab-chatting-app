//Packages
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloud_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/authentication_provider.dart';
import '../services/navigation_service.dart';
import '../services/database_service.dart' hide USER_COLLECTION;




// User model - Replace with your actual User model structure

AuthenticationProvider authenticationProvider = AuthenticationProvider(
  firebaseAuth: FirebaseAuth.instance,
  googleSignIn: GoogleSignIn(),
  navigationService: NavigationService(),
  databaseService: DatabaseService(),
);

  

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User? user;
  String? userName;
  String? userEmail;
  String? userImageURL;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    user = authenticationProvider.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await DatabaseService().getUser(user!.uid);
      userName = userData.get('name') as String?;
      userEmail = userData.get('email') as String?;
      userImageURL = userData.get('image') as String?;
      setState(() {});
    }
  }

  Future<void> changeProfilePhoto() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('images/users/${user!.uid}/profile.${file.extension}');

      UploadTask uploadTask = ref.putFile(
        File('${file.path}'),
      );

      TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        String? imageURL = await snapshot.ref.getDownloadURL();

        if (imageURL != null) {
          // Delete old image if it exists
          if (userImageURL != null) {
            await FirebaseStorage.instance.refFromURL(userImageURL!).delete();
          }

          // Update user's image URL in Firestore
          await FirebaseFirestore.instance
              .collection(USER_COLLECTION)
              .doc(user!.uid)
              .update({'image': imageURL});

          setState(() {
            userImageURL = imageURL;
          });
        } else {
          // Inform the user that the image upload failed
          // Handle this case according to your app's flow
          print('Image upload failed.');
        }
      }
    } else {
      // User didn't select an image
      // You can inform the user or handle this scenario accordingly
      print('No image selected.');
    }
  } catch (e) {
    // Handle other exceptions
    print('Error: $e');
    // Inform the user about the error
    // You might want to display a snackbar or toast to inform the user about the error
  }
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('User Profile'),
      backgroundColor: Colors.transparent, // Set the AppBar background color to transparent
      elevation: 0, // Remove the shadow below the AppBar
    ),
    body: Center(
      child: user != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: changeProfilePhoto,
                  child: Stack(
                    children: [
                      userImageURL != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(userImageURL!),
                              radius: 70,
                            )
                          : Container(), // Empty container if user image URL is not available
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromRGBO(139, 243, 193, 1),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: changeProfilePhoto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Name:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editUserName(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${userName ?? "Loading..."}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Email:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${userEmail ?? "No email"}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : CircularProgressIndicator(),
    ),
  );
}


  void _editUserName(BuildContext context) {
  TextEditingController _nameController = TextEditingController(text: userName);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text('Edit Name'),
        content: TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'New Name',
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              primary: const Color.fromARGB(255, 174, 0, 255), // Change the button's background color
            ),
            onPressed: () async {
              // Update the local state
              setState(() {
                userName = _nameController.text;
              });

              // Update the user's name in Firestore
              try {
                await FirebaseFirestore.instance
                    .collection('Users') // Replace 'Users' with your collection name
                    .doc(user!.uid)
                    .update({'name': _nameController.text});
                Navigator.pop(context);
              } catch (e) {
                print('Error updating name: $e');
              }
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      );
    },
  );
}
}

