import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class AddPermanentMember extends StatefulWidget {
  @override
  State<AddPermanentMember> createState() => _AddPermanentMemberState();
}

class _AddPermanentMemberState extends State<AddPermanentMember> {
  final TextEditingController nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? image;
  bool isDataUploaded = false;
  bool isUploading = false; // New state variable for upload status



  //////////////////////////////////
  /////  Get Image Face Token
  //////////////////////////////////

  Future<String?> getFaceToken(File imageFile) async {
    final apiKey = 'bND1JpVMS3hq5YqW3IeeeGpm1VXukJF2';
    final apiSecret = 'WxgDII3u5JJFtHFD0fJijmClE5TWZWlF';
    final url = Uri.parse('https://api-us.faceplusplus.com/facepp/v3/detect');

    var request = http.MultipartRequest('POST', url)
      ..fields['api_key'] = apiKey
      ..fields['api_secret'] = apiSecret
      ..fields['return_attributes'] = 'none';

    request.files.add(await http.MultipartFile.fromPath('image_file', imageFile.path));

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var json = jsonDecode(responseBody);
        var faces = json['faces'];
        if (faces.isNotEmpty) {
          return faces[0]['face_token'];
        } else {
          Fluttertoast.showToast(
            msg: "No face detected in the image.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return null;
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to get face token. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return null;
    }
  }


//====================================================
//========     TAKE IMAGES [G]     ===================
//====================================================

  Future<void> getImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }


//====================================================
//========     Store Data into Firebase     ==========
//====================================================

  Future<void> createData(String? faceToken) async {
    final username = nameController.text.trim();
    if (username.isEmpty || faceToken == null) {
      Fluttertoast.showToast(
        msg: "Error: Username or face token is empty.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      isUploading = true; // Start showing the circular progress indicator
    });

    try {
      await _firestore.collection("users").add({
        "Name": username,
        "Face_Token": faceToken,
      });
      setState(() {
        isDataUploaded = true;
        isUploading = false; // Stop showing the circular progress indicator
        image = null;
        nameController.clear();
      });
      Fluttertoast.showToast(
        msg: "Data uploaded successfully for $username.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() {
        isUploading = false; // Stop showing the circular progress indicator
      });
      Fluttertoast.showToast(
        msg: "Error uploading data: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }


//====================================================
//========      APPLICATOIN GUI     ===================
//====================================================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Face Recognition App"),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        backgroundColor: Colors.grey[300],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Add a New Permanent Member",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Enter Name",
                    labelStyle: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.blueAccent,
                    ),
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                image == null
                    ? Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: Text(
                    "Image is not selected",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: Image.file(
                    image!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: getImageFromGallery,
                      icon: Icon(Icons.image, color: Colors.white),
                      label: Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
                        if (pickedImage != null) {
                          setState(() {
                            image = File(pickedImage.path);
                          });
                        }
                      },
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),


                //////////////////////////////////////////
                ///// Get Face Token Method called
                /////////////////////////////////////////

                SizedBox(height: 30),
                isUploading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () async {
                    if (image != null) {
                      String? faceToken = await getFaceToken(image!);
                      if (faceToken != null) {
                        await createData(faceToken);
                      } else {
                        Fluttertoast.showToast(
                          msg: "Face token not generated.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                      }
                    } else {
                      Fluttertoast.showToast(
                        msg: "Please select an image first.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  },
                  child: Text("Upload", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
