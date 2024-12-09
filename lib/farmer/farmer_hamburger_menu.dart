import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'farmer_login.dart';
import 'farmer_user_data.dart'; // Import for accessing FarmerUserData

class FarmerHamburgerMenu extends StatelessWidget {
  final VoidCallback onLogout;

  FarmerHamburgerMenu({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final String? farmerUid = UserData().uid; // Get farmer's UID dynamically

    return Drawer(
      child: Column(
        children: [
          // Header with dynamic farmer data
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('Farmers').doc(farmerUid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: double.infinity,
                  color: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                return Container(
                  width: double.infinity,
                  color: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.agriculture, size: 80, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          'Welcome, Farmer',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        Text(
                          'No email available',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final farmerData = snapshot.data!.data() as Map<String, dynamic>;
              String? photoUrl = farmerData['photoUrl']; // Ensure 'photoUrl' field is used

              return Container(
                width: double.infinity,
                color: Colors.green, // Full-width green background
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Displaying the farmer's profile image or a placeholder if null
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl) // Use photoUrl from Firestore
                            : AssetImage('assets/placeholder.png') as ImageProvider, // Fallback placeholder
                      ),
                      SizedBox(height: 10),
                      Text(
                        farmerData['name'] ?? 'Welcome, Farmer',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      Text(
                        farmerData['email'] ?? 'No email available',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Menu Items
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text('Orders'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Messages'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          Divider(),
          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmerLogin(),
                ),
              );
              onLogout(); // Call the logout callback
            },
          ),
        ],
      ),
    );
  }
}
