import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buyer_user_data.dart'; // Import for accessing BuyerUserData
import 'buyer_login.dart';

class BuyerDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  BuyerDrawer({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final String? buyerUid = BuyerUserData().uid; // Get buyer's UID dynamically

    return Drawer(
      child: Column(
        children: [
          // Header with dynamic data
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('Buyers').doc(buyerUid).get(),
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
                        Icon(Icons.person, size: 80, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          'Welcome, Buyer',
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

              final buyerData = snapshot.data!.data() as Map<String, dynamic>;
              return Container(
                width: double.infinity,
                color: Colors.green, // Ensure full-width green background
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: buyerData['profileImage'] != null
                            ? NetworkImage(buyerData['profileImage'])
                            : AssetImage('assets/placeholder.png') as ImageProvider,
                      ),
                      SizedBox(height: 10),
                      Text(
                        buyerData['name'] ?? 'Welcome, Buyer',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      Text(
                        buyerData['email'] ?? 'No email available',
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
            leading: Icon(Icons.shopping_cart),
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
                  builder: (context) => BuyerLogin(),
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
