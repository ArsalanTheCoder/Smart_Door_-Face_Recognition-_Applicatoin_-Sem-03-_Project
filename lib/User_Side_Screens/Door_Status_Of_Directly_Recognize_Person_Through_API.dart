import 'package:flutter/material.dart';

class DoorStatusOfDirectlyRecognizePersonThroughApi extends StatefulWidget {
  final bool condition;
  const DoorStatusOfDirectlyRecognizePersonThroughApi({super.key, required this.condition});

  @override
  State<DoorStatusOfDirectlyRecognizePersonThroughApi> createState() => DoorStatusOfDirectlyRecognizePersonThroughApiState();
}

class DoorStatusOfDirectlyRecognizePersonThroughApiState extends State<DoorStatusOfDirectlyRecognizePersonThroughApi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gate Status'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[300],
      body: widget.condition
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gate is currently: Open',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 16),
            Icon(
              Icons.lock_open,
              color: Colors.green,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              'The door has been automatically opened.',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gate is currently: Closed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 16),
            Icon(
              Icons.lock,
              color: Colors.red,
              size: 100,
            ),
            SizedBox(height: 16),
            Text(
              'The door is closed and awaiting recognition.',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}


