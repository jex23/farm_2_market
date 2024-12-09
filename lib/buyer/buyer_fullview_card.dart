import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buyer_user_data.dart'; // Import for accessing buyer UID
import 'buyer_chat_conversation_page.dart';

class BuyerFullViewCard extends StatelessWidget {
  final Map<String, dynamic> post;

  BuyerFullViewCard({required this.post});

  void _showQuantityDialog(BuildContext context) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Quantity'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Quantity',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Ca'
                  'ncel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {
                  try {
                    await FirebaseFirestore.instance.collection('FarmerOrders').add({
                      'quantity': quantity,
                      'postId': post['id'], // Use the document ID of the product
                      'buyerUid': BuyerUserData().uid, // Buyer UID from user data
                      'timestamp': FieldValue.serverTimestamp(),
                      'status': "For Order",
                      'meetupstyle' : "Meetup"

                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order placed successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to place order: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid quantity.')),
                  );
                }
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          if (post['imageUrls'] != null && post['imageUrls'].isNotEmpty)
            Positioned.fill(
              child: Image.network(
                post['imageUrls'][0],
                fit: BoxFit.cover,
              ),
            )
          else
            Positioned.fill(
              child: Image.asset(
                'assets/placeholder.png',
                fit: BoxFit.cover,
              ),
            ),
          // Content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Icon(Icons.favorite_border, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          // Product details
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₱${post['priceStart']} - ₱${post['priceEnd']}',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.favorite_border, color: Colors.grey),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    post['title'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Distance and rating
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        '${post['distance'] ?? 'N/A'} km',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 5),
                      Text(
                        '${post['rating'] ?? 'N/A'} rating',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Description
                  Text(
                    post['description'] ??
                        'No description available for this product.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Seller information
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('Farmers')
                        .doc(post['uid'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Text('Seller information unavailable');
                      }
                      final seller = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (seller['photoUrl'] != null)
                            CircleAvatar(
                              backgroundImage: NetworkImage(seller['photoUrl']),
                              radius: 30,
                            ),
                          SizedBox(height: 8),
                          Text(
                            'Seller: ${seller['name'] ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Address: ${seller['address'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Contact: ${seller['phone'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  // Buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _showQuantityDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: Icon(Icons.shopping_cart, color: Colors.white),
                        label: Text(
                          'Buy Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BuyerChatConversationPage(
                                farmerUid: post['uid'], // Farmer UID
                                farmerName: 'Farmer Name', // Replace with actual farmer name
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: Icon(Icons.chat, color: Colors.white),
                        label: Text(
                          'Chat Seller',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                      ,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
