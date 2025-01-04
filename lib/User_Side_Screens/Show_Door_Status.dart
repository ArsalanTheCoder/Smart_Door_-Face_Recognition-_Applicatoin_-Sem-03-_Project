import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowDoorStatus extends StatefulWidget {
  const ShowDoorStatus({super.key});

  @override
  State<ShowDoorStatus> createState() => _ShowDoorStatusState();
}

class _ShowDoorStatusState extends State<ShowDoorStatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gate Status'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
     backgroundColor: Colors.grey[300],
      body: Center(
       // if(condition) {}
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('responses')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No responses yet.'));
            }

            // Get the latest document
            var doc = snapshot.data!.docs.first;
            var status = doc['status'] as bool;
            var email = doc['email'] as String;
            var timestamp = (doc['timestamp'] as Timestamp).toDate();

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gate is currently: ${status ? 'Open' : 'Closed'}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                   Center(
                     child: Text(
                       '     \tLast response from: $email',
                       style: TextStyle(fontSize: 18),
                     ),
                   ),

                  SizedBox(height: 15),
                  Center(
                    child: Text(
                      'Response time: ${timestamp.toLocal()}',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 32),
                  Icon(
                    status ? Icons.lock_open : Icons.lock,
                    color: status ? Colors.green : Colors.red,
                    size: 100,
                  ),
                ],
              ),
            );
          },

        ),
      ),
    );
  }
}
