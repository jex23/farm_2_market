import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'buyer_user_data.dart';
import 'buyer_chat_conversation_page.dart'; // Import the chat page

class BuyerMessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? buyerUid = BuyerUserData().uid; // Access buyerUid from BuyerUserData

    if (buyerUid == null) {
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
            .where('buyerUid', isEqualTo: buyerUid) // Filter by buyerUid
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
              final farmerUid = chatData['farmerUid'];
              final lastMessageTimestamp = chatData['lastMessageTimestamp'] as Timestamp?;
              final formattedDate = lastMessageTimestamp != null
                  ? DateFormat('MMM dd, yyyy - hh:mm a')
                  .format(lastMessageTimestamp.toDate())
                  : 'No date available';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Farmers')
                    .doc(farmerUid)
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
                        title: Text('Farmer info unavailable'),
                        subtitle: Text('Cannot fetch farmer details.'),
                      ),
                    );
                  }

                  final farmerData = snapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: farmerData['photoUrl'] != null
                            ? NetworkImage(farmerData['photoUrl'])
                            : null,
                        backgroundColor: Colors.green,
                        child: farmerData['photoUrl'] == null
                            ? Text(
                          farmerData['name'][0],
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                            : null,
                      ),
                      title: Text(farmerData['name'] ?? 'Unknown Farmer'),
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
                            builder: (context) => BuyerChatConversationPage(
                              farmerUid: farmerUid,
                              farmerName: farmerData['name'] ?? 'Unknown Farmer',
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
