import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditFarmerProfilePage.dart';
import 'farmer_user_data.dart'; // Farmer's user data class

class FarmerProfilePage extends StatelessWidget {
  final String? farmerUid = UserData().uid; // Access farmer UID

  @override
  Widget build(BuildContext context) {
    if (farmerUid == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Text(
            'User not logged in.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Farmers')
            .doc(farmerUid)
            .snapshots(), // Listen for changes in the Firestore document
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to fetch profile information.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          final farmerData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: farmerData['photoUrl'] != null
                      ? NetworkImage(farmerData['photoUrl'])
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: farmerData['photoUrl'] == null
                      ? Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  )
                      : null,
                ),
                SizedBox(height: 20),
                Text(
                  farmerData['name'] ?? 'Unknown Name',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  farmerData['email'] ?? 'Unknown Email',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                _buildProfileDetail('Phone:', farmerData['phone'] ?? 'N/A'),
                _buildProfileDetail('Address:', farmerData['address'] ?? 'N/A'),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditFarmerProfilePage(
                          farmerData: farmerData,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
