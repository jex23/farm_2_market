import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'buyer_orders.dart';
import 'buyer_messages.dart';
import 'buyer_profile.dart';
import 'buyer_categories.dart';
import 'buyer_fullview_card.dart';
import 'buyer_drawer.dart';

class BuyerHomePage extends StatefulWidget {
  @override
  _BuyerHomePageState createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }
  void _handleLogout() {
    // Add your logout logic here
    print('User logged out');
  }
  List<Widget> _buildScreens() {
    return [
      BuyerHomeScreen(),
      BuyerOrdersScreen(),
      BuyerMessagesScreen(),
      BuyerProfileScreen(),
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
        icon: Icon(Icons.shopping_cart),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/first page logo.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text('Buyer Market'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      drawer: BuyerDrawer(onLogout: _handleLogout),
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

class BuyerHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Hello, John!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),

            // Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildCategoryItem(context, Icons.rice_bowl, 'Rice'),
                _buildCategoryItem(context, Icons.apple, 'Fruits'),
                _buildCategoryItem(context, Icons.eco, 'Vegetable'),
                _buildCategoryItem(context, Icons.local_dining, 'Meat & Chicken'),
              ],
            ),
            SizedBox(height: 20),

            // Popular Products Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Farm Product',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Posts Section
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('FarmerPost').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No popular products available',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final post = doc.data() as Map<String, dynamic>;
                    post['id'] = doc.id; // Add the document ID to the post data
                    return _buildProductCard(context, post);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyerCategories(category: title),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Icon(icon, color: Colors.green),
          ),
          SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyerFullViewCard(post: post),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            if (post['imageUrls'] != null && post['imageUrls'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  post['imageUrls'][0],
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['title'] ?? 'No Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('₱${post['priceStart']} - ₱${post['priceEnd']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
