import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'farmer_user_data.dart'; // Farmer's user data class
import 'farmer_chat_conversation_page.dart'; // Farmer chat conversation page

class FarmerMessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? farmerUid = UserData().uid; // Access farmerUid from UserData

    if (farmerUid == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Messages'),
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
        title: Text('Messages'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Chats')
            .where('farmerUid', isEqualTo: farmerUid) // Filter by farmerUid
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No messages yet. Start a conversation!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              final buyerUid = chatData['buyerUid'];
              final lastMessageTimestamp = chatData['lastMessageTimestamp'] as Timestamp?;
              final formattedDate = lastMessageTimestamp != null
                  ? DateFormat('MMM dd, yyyy - hh:mm a')
                  .format(lastMessageTimestamp.toDate())
                  : 'No date available';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Buyers') // Retrieve data from Buyers collection
                    .doc(buyerUid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                        ),
                        title: Text('Loading...'),
                        subtitle: Text('Fetching data...'),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.hasError) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                        ),
                        title: Text('Buyer info unavailable'),
                        subtitle: Text('Cannot fetch buyer details.'),
                      ),
                    );
                  }

                  final buyerData = snapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: buyerData['profileImage'] != null
                            ? NetworkImage(buyerData['profileImage'])
                            : null,
                        backgroundColor: Colors.green,
                        child: buyerData['profileImage'] == null
                            ? Text(
                          buyerData['name'][0],
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                            : null,
                      ),
                      title: Text(buyerData['name'] ?? 'Unknown Buyer'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(chatData['lastMessage'] ?? 'No messages yet.'),
                          SizedBox(height: 5),
                          Text(
                            formattedDate,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FarmerChatConversationPage(
                              buyerUid: buyerUid,
                              buyerName: buyerData['name'] ?? 'Unknown Buyer',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
