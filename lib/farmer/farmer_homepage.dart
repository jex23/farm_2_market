import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'farmer_order_page.dart';
import 'farmer_messages_page.dart';
import 'farmer_profile_page.dart';
import 'farmer_hamburger_menu.dart';
import 'farmer_create_post.dart';
import 'farmer_user_data.dart';

class FarmerHomePage extends StatefulWidget {
  @override
  _FarmerHomePageState createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      FarmerOrderPage(),
      FarmerMessagesScreen(),
      FarmerProfilePage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: 'Home',
        activeColorPrimary: Colors.green,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.list_alt),
        title: 'Orders',
        activeColorPrimary: Colors.green,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.message),
        title: 'Messages',
        activeColorPrimary: Colors.green,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        title: 'Profile',
        activeColorPrimary: Colors.green,
        activeColorSecondary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  void _handleLogout() {
    print('User logged out');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.agriculture, size: 40, color: Colors.white),
            SizedBox(width: 10),
            Text('Farm2Market'),
          ],
        ),
      ),
      drawer: FarmerHamburgerMenu(onLogout: _handleLogout),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarItems(),
        navBarStyle: NavBarStyle.style7,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/first page logo.png',
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Transaction',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.green,
                    tabs: [
                      Tab(text: 'New Order'),
                      Tab(text: 'Done'),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search here',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to FarmerCreatePost
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FarmerCreatePost(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      children: [
                        NewOrderPost(), // Display posts in this tab
                        Center(
                          child: Text(
                            'No completed orders yet.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewOrderPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the farmer's UID from the UserData singleton
    final String farmerUid = UserData().uid ?? ''; // Get the UID (handle null if necessary)

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('FarmerPost')
          .where('uid', isEqualTo: farmerUid) // Filter by UID
          .snapshots(),
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
                        if (post['imageUrls'] != null && post['imageUrls'].isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              post['imageUrls'][0],
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


