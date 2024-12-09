import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'farmer_user_data.dart'; // Farmer user data class

class FarmerChatConversationPage extends StatefulWidget {
  final String buyerUid;
  final String buyerName; // Optional: Pass as fallback if not fetched

  FarmerChatConversationPage({required this.buyerUid, required this.buyerName});

  @override
  _FarmerChatConversationPageState createState() =>
      _FarmerChatConversationPageState();
}

class _FarmerChatConversationPageState
    extends State<FarmerChatConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final String? farmerUid = UserData().uid;

  @override
  Widget build(BuildContext context) {
    if (farmerUid == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
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

    final String chatId = farmerUid!.compareTo(widget.buyerUid) > 0
        ? '$farmerUid-${widget.buyerUid}'
        : '${widget.buyerUid}-$farmerUid';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('Buyers')
              .doc(widget.buyerUid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Loading...',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              );
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.buyerName, // Fallback to the passed name
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              );
            }

            final buyerData = snapshot.data!.data() as Map<String, dynamic>;

            return Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CircleAvatar(
                  backgroundImage: buyerData['profileImage'] != null
                      ? NetworkImage(buyerData['profileImage'])
                      : null,
                  backgroundColor: Colors.green,
                  child: buyerData['profileImage'] == null
                      ? Text(
                    buyerData['name'][0] ?? 'B',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                      : null,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buyerData['name'] ?? widget.buyerName,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(chatId)
                  .collection('Messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                    messages[index].data() as Map<String, dynamic>;
                    final isFarmerMessage =
                        messageData['senderId'] == farmerUid;

                    return Align(
                      alignment: isFarmerMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isFarmerMessage ? Colors.green : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          messageData['message'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: isFarmerMessage ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type message ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final String chatId = farmerUid!.compareTo(widget.buyerUid) > 0
        ? '$farmerUid-${widget.buyerUid}'
        : '${widget.buyerUid}-$farmerUid';

    final messageData = {
      'senderId': farmerUid,
      'receiverId': widget.buyerUid,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Save the message
    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('Messages')
        .add(messageData);

    // Update chat metadata for listing
    await FirebaseFirestore.instance.collection('Chats').doc(chatId).set({
      'lastMessage': _messageController.text.trim(),
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'buyerUid': widget.buyerUid,
      'farmerUid': farmerUid,
    });

    _messageController.clear();
  }
}
