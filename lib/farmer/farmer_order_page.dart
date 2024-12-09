import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'farmer_user_data.dart'; // Import for accessing UserData
import 'package:intl/intl.dart'; // For date formatting

class FarmerOrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final farmerUid = UserData().uid; // Get farmer's UID dynamically

    return Scaffold(
      appBar: AppBar(
        title: Text('Farmer Orders'),
        backgroundColor: Colors.green,
      ),
      body: farmerUid == null
          ? Center(
        child: Text(
          'User not logged in.',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('FarmerPost')
            .where('uid', isEqualTo: farmerUid) // Match farmer UID
            .snapshots(),
        builder: (context, farmerSnapshot) {
          if (farmerSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!farmerSnapshot.hasData || farmerSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No products found for your account.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          final farmerPostIds =
          farmerSnapshot.data!.docs.map((doc) => doc.id).toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('FarmerOrders')
                .where('postId', whereIn: farmerPostIds) // Match orders with farmer's posts
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!orderSnapshot.hasData || orderSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No orders available.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                );
              }

              return ListView.builder(
                itemCount: orderSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final orderDoc = orderSnapshot.data!.docs[index];
                  final orderData = orderDoc.data() as Map<String, dynamic>;

                  return _buildOrderCard(orderData, orderDoc.id);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> orderData, String orderId) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    // Product and Order Details
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
                          SizedBox(height: 4),
                          Text(
                            '₱${post['priceStart']} - ₱${post['priceEnd']}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Quantity: ${orderData['quantity']}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('Buyers')
                                .doc(orderData['buyerUid'])
                                .get(),
                            builder: (context, buyerSnapshot) {
                              if (buyerSnapshot.connectionState == ConnectionState.waiting) {
                                return Text(
                                  'Loading buyer details...',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                );
                              }

                              if (!buyerSnapshot.hasData || !buyerSnapshot.data!.exists) {
                                return Text(
                                  'Buyer information unavailable',
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                );
                              }

                              final buyer = buyerSnapshot.data!.data() as Map<String, dynamic>;

                              return Text(
                                'Ordered by: ${buyer['name'] ?? 'Unknown Buyer'}',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              );
                            },
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Order Date: ${DateFormat('MMMM dd, yyyy').format(orderData['timestamp'].toDate())}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Status and Meetup Style Dropdowns
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Dropdown with Color
                    Column(
                      children: [
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
                        DropdownButton<String>(
                          value: orderData['status'] ?? 'Process',
                          underline: SizedBox(),
                          onChanged: (String? newStatus) {
                            if (newStatus != null) {
                              FirebaseFirestore.instance
                                  .collection('FarmerOrders')
                                  .doc(orderId)
                                  .update({'status': newStatus});
                            }
                          },
                          items: <String>['Process', 'Completed', 'Canceled']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Meetup Style Dropdown with Color
                    Column(
                      children: [
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
                        DropdownButton<String>(
                          value: orderData['meetupStyle'] ?? 'Meet-up',
                          underline: SizedBox(),
                          onChanged: (String? newStyle) {
                            if (newStyle != null) {
                              FirebaseFirestore.instance
                                  .collection('FarmerOrders')
                                  .doc(orderId)
                                  .update({'meetupStyle': newStyle});
                            }
                          },
                          items: <String>['Meet-up', 'For Pickup']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
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
