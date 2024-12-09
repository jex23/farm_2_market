import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'farmer_homepage.dart';
import 'farmer_signup.dart';
import 'farmer_user_data.dart';

class FarmerLogin extends StatefulWidget {
  @override
  _FarmerLoginState createState() => _FarmerLoginState();
}

class _FarmerLoginState extends State<FarmerLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for email and password input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Login method
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email exists in the 'Farmers' collection
      final email = _emailController.text.trim();
      final emailQuery = await _firestore
          .collection('Farmers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (emailQuery.docs.isEmpty) {
        // If email does not exist in Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email not found in our records.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Proceed with Firebase authentication if email exists
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // Store the uid globally after successful login
      UserData().uid = userCredential.user!.uid;

      // Navigate to FarmerHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FarmerHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Farmer Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/first page logo.png',
                  height: 100,
                ),
                SizedBox(height: 20),
                Text(
                  'Farmer Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FarmerSignup()),
                    );
                  },
                  child: Text(
                    'Don’t have an account? Sign up',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
