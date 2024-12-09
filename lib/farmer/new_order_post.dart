import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewOrderPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('FarmerPost').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No posts available',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final post = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Reference Number',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Post ID: ${snapshot.data!.docs[index].id}'),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          if (post['imageUrls'] != null &&
                              post['imageUrls'].isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                post['imageUrls'][0], // First image
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/placeholder.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          SizedBox(width: 10),
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
                                Text('Category: ${post['category'] ?? 'N/A'}'),
                                Text('Price: ${post['priceStart']} - ${post['priceEnd']} PHP'),
                                Text('Minimum Order: ${post['minOrder'] ?? 'N/A'}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('Description:'),
                      Text(
                        post['description'] ?? 'No description provided',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 10),
                      Text('Pickup Location:'),
                      Text(
                        post['address'] ?? 'No address provided',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Logic for "Ready for Pickup" action
                          print('Ready for Pickup pressed for post ID: ${snapshot.data!.docs[index].id}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Ready for Pickup'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
