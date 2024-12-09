import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buyer_user_data.dart'; // Import for accessing BuyerUserData
import 'package:intl/intl.dart'; // For date formatting

class BuyerOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buyerUid = BuyerUserData().uid; // Get buyer's UID dynamically

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: Colors.green,
      ),
      body: buyerUid == null
          ? Center(
        child: Text(
          'User not logged in.',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('FarmerOrders')
            .where('buyerUid', isEqualTo: buyerUid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'You have no orders yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final orderDoc = snapshot.data!.docs[index];
              final orderData = orderDoc.data() as Map<String, dynamic>;

              return _buildOrderCard(orderData);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> orderData) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('FarmerPost')
              .doc(orderData['postId'])
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(
                'Product information unavailable',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              );
            }

            final post = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: post['imageUrls'] != null &&
                          post['imageUrls'].isNotEmpty
                          ? Image.network(
                        post['imageUrls'][0],
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        'assets/placeholder.png',
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['title'] ?? 'No Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '₱${post['priceStart']} - ₱${post['priceEnd']}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Quantity: ${orderData['quantity']}',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Ordered on: ${DateFormat('MMMM dd, yyyy').format(orderData['timestamp'].toDate())}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 5),
                          // Farmer Address
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('Farmers')
                                .doc(post['uid'])
                                .get(),
                            builder: (context, farmerSnapshot) {
                              if (farmerSnapshot.connectionState == ConnectionState.waiting) {
                                return Text(
                                  'Loading farmer details...',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                );
                              }

                              if (!farmerSnapshot.hasData || !farmerSnapshot.data!.exists) {
                                return Text(
                                  'Farmer address unavailable',
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                );
                              }

                              final farmer = farmerSnapshot.data!.data() as Map<String, dynamic>;

                              return Text(
                                'Farmer Address: ${farmer['address'] ?? 'N/A'}',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Display
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(orderData['status'] ?? 'Process'),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        orderData['status'] ?? 'Process',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // MeetupStyle Display
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _getMeetupStyleColor(orderData['meetupStyle'] ?? 'Meet-up'),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        orderData['meetupStyle'] ?? 'Meet-up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.blue;
      case 'Canceled':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // Helper function to get meetup style color
  Color _getMeetupStyleColor(String meetupStyle) {
    switch (meetupStyle) {
      case 'For Pickup':
        return Colors.orange;
      default:
        return Colors.purple; // Default for 'Meet-up'
    }
  }
}
