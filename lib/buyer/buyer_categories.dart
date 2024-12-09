import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buyer_fullview_card.dart';

class BuyerCategories extends StatelessWidget {
  final String category;

  BuyerCategories({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('FarmerPost')
              .where('category', isEqualTo: category)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No products available in $category',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final post = doc.data() as Map<String, dynamic>;
                post['id'] = doc.id; // Add the document ID to the post data

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuyerFullViewCard(post: post),
                      ),
                    );
                  },
                  child: _buildProductCard(post),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> post) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: post['imageUrls'] != null && post['imageUrls'].isNotEmpty
                  ? Image.network(
                post['imageUrls'][0],
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/placeholder.png',
                height: 80,
                width: 80,
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
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('Farmers')
                        .doc(post['uid']) // Use the seller's UID
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Loading seller...',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Error fetching seller',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        );
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text(
                          'Seller not found',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        );
                      }

                      final sellerData =
                      snapshot.data!.data() as Map<String, dynamic>;
                      return Text(
                        sellerData['name'] ?? 'Unknown Seller',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      );
                    },
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Min Order: ${post['minOrder'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.add_shopping_cart,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
