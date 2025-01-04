import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Add_Permanent_Member.dart';
import 'Remove_Permanent_Member.dart';
import 'View_All_Permanent_Members.dart';

class AddviewremoveMemberInDatabase extends StatefulWidget {
  const AddviewremoveMemberInDatabase({super.key});

  @override
  State<AddviewremoveMemberInDatabase> createState() => _AddviewremoveMemberInDatabaseState();
}

class _AddviewremoveMemberInDatabaseState extends State<AddviewremoveMemberInDatabase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Screen", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 5,
      ),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 20),
            _buildCard(
              context,
              'Add',
              'Add a new permanent member to the database.',
              Icons.add_circle,
              Colors.green,
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddPermanentMember()));
              },
            ),
            SizedBox(height: 20),
            _buildCard(
              context,
              'Remove',
              'Remove a permanent member from the database.',
              Icons.remove_circle,
              Colors.red,
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RemoveMemberScreen()));
              },
            ),
            SizedBox(height: 20),
            _buildCard(
              context,
              'View',
              'View all the permanent members in the database.',
              Icons.visibility,
              Colors.blue,
                  () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewAllPermanentMembers()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 50,
                color: color,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
