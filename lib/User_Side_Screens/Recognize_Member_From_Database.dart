import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_links/uni_links.dart';
import 'Door_Status_Of_Directly_Recognize_Person_Through_API.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Show_Door_Status.dart';



bool isMatch=false;
bool EmailResponse=false;
bool _isRecognizing = false;
late String? ReceiverEmail;
class RecognizeMemberFromDatabase extends StatefulWidget {
  final String? userEmail;

  RecognizeMemberFromDatabase({Key? key,  this.userEmail}) : super(key: key);

  @override
  State<RecognizeMemberFromDatabase> createState() => _RecognizeMemberFromDatabaseState();
}

class _RecognizeMemberFromDatabaseState extends State<RecognizeMemberFromDatabase> {
  String? _resultMessage;
  File? newImage;


//====================================================
//========   GET FACE TOKEN USING FACE++ API  ========
//====================================================

  Future<String?> getFaceToken(File imageFile) async {
    final apiKey = 'bND1JpVMS3hq5YqW3IeeeGpm1VXukJF2';
    final apiSecret = 'WxgDII3u5JJFtHFD0fJijmClE5TWZWlF';
    final url = Uri.parse('https://api-us.faceplusplus.com/facepp/v3/detect');

    var request = http.MultipartRequest('POST', url)
      ..fields['api_key'] = apiKey
      ..fields['api_secret'] = apiSecret;

    request.files.add(
        await http.MultipartFile.fromPath('image_file', imageFile.path));

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var json = jsonDecode(responseBody);
        var faces = json['faces'];
        if (faces.isNotEmpty) {
          return faces[0]['face_token'];
        } else {
          print("No face detected in the image.");
          return null;
        }
      } else {
        print("Failed to get face token. Error: ${responseBody}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }


//====================================================
//======= COMPARE FACE TOKEN USING FACE++ API  =======
//====================================================

  Future<bool> compareFaceTokens(String faceToken1, String faceToken2) async {
    final apiKey = 'bND1JpVMS3hq5YqW3IeeeGpm1VXukJF2';
    final apiSecret = 'WxgDII3u5JJFtHFD0fJijmClE5TWZWlF';
    final url = Uri.parse('https://api-us.faceplusplus.com/facepp/v3/compare');

    var response = await http.post(url, body: {
      'api_key': 'bND1JpVMS3hq5YqW3IeeeGpm1VXukJF2',
      'api_secret': 'WxgDII3u5JJFtHFD0fJijmClE5TWZWlF',
      'face_token1': faceToken1,
      'face_token2': faceToken2,
    });

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      double confidence = jsonResponse['confidence'];
      return confidence > 80;
    } else {
      print("Comparison failed: ${response.body}");
      return false;
    }
  }

  Future<void> recognizePerson(File image) async {
    // Attempt to retrieve the face token from the image
    String? newFaceToken = await getFaceToken(image);
    print("NewFace Token $newFaceToken");
    if (newFaceToken == null) {
      setState(() {
        _resultMessage = "No face detected in the image.";
      });
      return;
    }

    // Access the Firestore collection
    final collection = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await collection.get();

    // Iterate through the documents to compare face tokens
    for (var doc in querySnapshot.docs) {
      try {
        // Safely retrieve the Face_Token field
        String? storedFaceToken = doc.data()['Face_Token'];
        String? storedUserName = doc.data()['Name'];

        if (storedFaceToken == null) {
          print('Warning: Document ${doc
              .id} does not contain a Face_Token field.');
          continue; // Skip to the next document
        }

        // Compare face tokens
        isMatch = await compareFaceTokens(newFaceToken, storedFaceToken);
        print("API Response for Send function Result: ${isMatch.toString()} and ");
        if (isMatch) {
          setState(() {
            _resultMessage = "Image found! Matched with ${storedUserName}";
          });
          print("Result of Face API: ${isMatch.toString()}");

          // Additional check to update UI or perform actions before navigation
          await Future.delayed(const Duration(
              milliseconds: 500)); // Small delay for smoother transition

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DoorStatusOfDirectlyRecognizePersonThroughApi(
                    condition: isMatch,
                  ),
            ),
          );
          return; // Exit function if a match is found
        }
      } catch (e) {
        // Handle errors for individual documents
        print("Error processing document ${doc.id}: $e");
        continue; // Move to the next document
      }
    }

    setState(() {
      _resultMessage = "No match found.";
    });

    // Send email to home owner
    if (!isMatch) {
      await SendEmailAndGetResponse();

      // Additional log to confirm the email send process
      print("Email sent to homeowner for unrecognized face.");
    }
  }

  Future<void> SendEmailAndGetResponse() async {
    print("API Response for Send function Result: ${isMatch
        .toString()} and ${isMatch == false}");

    if (isMatch == false) {
      var emailService = EmailService();

      await emailService.initializeFirebase();
      await emailService.sendEmail();
      bool conditoin = emailService.setupDeepLinkListener() as bool;

      print("API Response for Send function Result: ${EmailResponse
          .toString()} and ${conditoin.toString()}");

      return;
    } else {
      print("Email not send");
    }
  }


//====================================================
//========     TAKE IMAGES [G]     ===================
//====================================================

  Future<void> getNewCustomerImage() async {
    final _pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (_pickedImage != null) {
      setState(() {
        newImage = File(_pickedImage.path);
        _resultMessage = null; // Reset the result message
      });
    }
  }

  void initState() {
    super.initState();
    // Assigning the passed userEmail to the ReceiverEmail variable
    ReceiverEmail = widget.userEmail;
  }


//====================================================
//========      APPLICATOIN GUI     ==================
//====================================================

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Face Recognition", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        backgroundColor: Colors.grey[300],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display container or selected image
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: newImage != null ? 250 : 150,
                  width: newImage != null ? 250 : 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    image: newImage != null
                        ? DecorationImage(
                      image: FileImage(newImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: newImage == null
                      ? Center(
                    child: Text(
                      "No Image Selected",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  )
                      : null,
                ),
                SizedBox(height: 20),

                // Buttons for Camera, Gallery, and Recognize
                if (newImage == null) ...[
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: getNewCustomerImage,
                            child: Row(
                              children: [
                                Icon(Icons.photo),
                                SizedBox(width: 5),
                                Text("Gallery"),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final _pickedImage =
                              await ImagePicker().pickImage(
                                  source: ImageSource.camera);
                              if (_pickedImage != null) {
                                setState(() {
                                  newImage = File(_pickedImage.path);
                                  _resultMessage = null;
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Icon(Icons.camera_alt),
                                SizedBox(width: 5),
                                Text("Camera"),
                              ],
                            ),
                          ),
                        ],
                      ),
                     SizedBox(height: 35),
                     Text(
                       "Select an Image to Recognize...",
                       style: TextStyle(
                         fontSize: 17,
                         fontWeight: FontWeight.bold,
                         color: Colors.blueGrey,
                         letterSpacing: 1.2,
                       ),
                       textAlign: TextAlign.center,
                     ),

                    ],
                  ),
                  SizedBox(height: 20),
                ],

                // Recognize button
                if (newImage != null)
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isRecognizing = true;
                      });
                      try {
                        await recognizePerson(newImage!);
                        Fluttertoast.showToast(
                            msg: _resultMessage ?? "Operation complete!",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM);
                      } catch (e) {
                        // Fluttertoast.showToast(
                        //     msg: "Error: $e",
                        //     toastLength: Toast.LENGTH_LONG,
                        //     gravity: ToastGravity.BOTTOM);
                      } finally {
                        setState(() {
                          _isRecognizing = false;
                        });
                      }
                    },
                    child: Text("Recognize Image"),
                  ),

                // Circular progress indicator
                if (_isRecognizing)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),

                SizedBox(height: 20),

                // Result message container
                if (!_isRecognizing && _resultMessage != null)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _resultMessage!,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),

                SizedBox(height: 20),

                // Clear and See Door Status Buttons
                if (!_isRecognizing && newImage != null &&
                    _resultMessage != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            newImage = null;
                            _resultMessage = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        child: Text("Clear"),
                      ),
                      if (_resultMessage == "No match found.")
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowDoorStatus(),
                              ),
                            );
                          },
                          child: Text("See Door Status"),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



//====================================================
//========       SENDING EMAIL     ===================
//====================================================


class EmailService {
  late StreamSubscription _sub;
  bool _isListenerInitialized = false; // Ensure listener setup only once
  String? _lastProcessedLink; // Track last processed link

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> sendEmail() async {
  //431 line here
    var url = Uri.parse('https://api.brevo.com/v3/smtp/email');
    var headers = {
  // here 435 line
      'Content-Type': 'application/json',
    };

    String htmlContent = '''
    <!DOCTYPE html>
    <html>
      <head>
        <style>
          body {
            font-family: Arial, sans-serif;
            text-align: center;
            background-color: #f9f9f9;
            color: #333;
            margin: 0;
            padding: 20px;
          }
          .container {
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
            padding: 20px;
            max-width: 600px;
            margin: auto;
          }
          h1 {
            color: #4CAF50;
            font-size: 24px;
          }
          p {
            font-size: 16px;
            line-height: 1.6;
          }
          img {
            max-width: 100%;
            border-radius: 10px;
            margin-top: 20px;
            margin-bottom: 20px;
          }
          .buttons {
            margin-top: 30px;
          }
          .btn {
            display: inline-block;
            padding: 15px 30px;
            font-size: 16px;
            font-weight: bold;
            text-decoration: none;
            border-radius: 5px;
            margin: 10px;
            color: #fff;
          }
          .btn-approve {
            background-color: #4CAF50;
          }
          .btn-deny {
            background-color: #F44336;
          }
          .footer {
            margin-top: 20px;
            font-size: 14px;
            color: #666;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Do You Want to Give Permission to This Person?</h1>
          <p>We noticed an attempt to access your premises. Kindly confirm if you want to grant permission to this individual.</p>
          <img src="https://github.com/Mohammad-Arsalan521/flutter_greeting_application/blob/main/image.jpg?raw=true" alt="Stranger's Photo"/>
          <div class="buttons">
            <a href="myapp://response?status=TRUE" class="btn btn-approve">Approve</a>
            <a href="myapp://response?status=FALSE" class="btn btn-deny">Deny</a>
          </div>
          <div class="footer">
            <p>This is an automated email. If you have any concerns, please contact our support team.</p>
          </div>
        </div>
      </body>
    </html>
    ''';

    var body = jsonEncode({
      "sender": {"email": "kingarain7866@gmail.com"},
      "to": [
        {"email": ReceiverEmail}
      ],
      "subject": "Get Permission",
      "htmlContent": htmlContent,
      "textContent": "Hello from Flutter in plain text.",
    });

     // print("Receiver Email here: $ReceiverEmail");
    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Email sent successfully');
    } else {
      print('Failed to send email: ${response.body}');
    }
  }

  Future<bool> setupDeepLinkListener() async {
    final completer = Completer<bool>(); // Create a completer to await the response

    if (_isListenerInitialized) return completer.future;

    _sub = getLinksStream().listen((String? link) {
      if (link != null) {
        print('Received link: $link');
        processDeepLink(link);

        // Resolve the completer when a valid response is received
        if (EmailResponse != null) {
          completer.complete(EmailResponse);
          _sub.cancel(); // Stop listening after response is received
          _isListenerInitialized = false;
        }
      }
    }, onError: (err) {
      print('Error receiving link: $err');
      completer.completeError(err); // Handle error
    });

    _isListenerInitialized = true;
    return completer.future; // Return the future that resolves when the response is received
  }

  bool processDeepLink(String link)  {
    if (link == _lastProcessedLink) return false; // Ignore duplicate links
    _lastProcessedLink = link;

    Uri uri = Uri.parse(link);
    String? status = uri.queryParameters['status'];

    if (status == null) {
      print('Invalid link received!');
      return false;
    }

    if (status == 'TRUE') {
      storeResponse(true);
      //EmailResponse=true;
      print('Permission Granted!');
      return true;
    } else if (status == 'FALSE') {
      // EmailResponse=false;
      storeResponse(false);
      print('Permission Denied!');
      return false;
    }
    return false;
  }

  Future<void> storeResponse(bool granted) async {
    EmailResponse=granted;
    try {
      await FirebaseFirestore.instance.collection('responses').add({
        'status': granted,
        'email': 'arainyaseen04@gmail.com', // Optional: Include request details
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Response stored successfully: $granted');
    } catch (e) {
      print('Failed to store response: $e');
    }
  }

  void dispose() {
    _sub.cancel(); // Cancel listener when no longer needed
  }
}




