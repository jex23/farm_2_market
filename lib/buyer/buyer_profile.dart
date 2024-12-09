import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditBuyerProfilePage.dart';
import 'buyer_user_data.dart'; // Your BuyerUserData class for accessing the buyer's UID

class BuyerProfileScreen extends StatelessWidget {
  final String? buyerUid = BuyerUserData().uid; // Access buyer UID from the singleton BuyerUserData class

  @override
  Widget build(BuildContext context) {
    if (buyerUid == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Buyer Profile'),
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
        title: Text('Buyer Profile'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Buyers')
            .doc(buyerUid)
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

          final buyerData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: buyerData['photoUrl'] != null
                      ? NetworkImage(buyerData['photoUrl'])
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: buyerData['photoUrl'] == null
                      ? Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  )
                      : null,
                ),
                SizedBox(height: 20),
                Text(
                  buyerData['name'] ?? 'Unknown Name',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  buyerData['email'] ?? 'Unknown Email',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                _buildProfileDetail('Phone:', buyerData['phone'] ?? 'N/A'),
                _buildProfileDetail('Address:', buyerData['address'] ?? 'N/A'),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBuyerProfilePage(
                          buyerData: buyerData,
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
