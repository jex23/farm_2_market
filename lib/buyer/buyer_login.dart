import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'buyer_signup.dart';
import 'buyer_user_data.dart';
import 'buyer_homepage.dart';

class BuyerLogin extends StatefulWidget {
  @override
  _BuyerLoginState createState() => _BuyerLoginState();
}

class _BuyerLoginState extends State<BuyerLogin> {
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
      // Check if email exists in the 'Buyers' collection
      final email = _emailController.text.trim();
      final emailQuery = await _firestore
          .collection('Buyers')
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

      // Authenticate user with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // Store UID in the BuyerUserData singleton
      BuyerUserData().uid = userCredential.user!.uid;

      // Navigate to Buyer Homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BuyerHomePage(),
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/first page logo.png',
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Buyer Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email, color: Colors.green),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock, color: Colors.green),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuyerSignup(), // Navigate to BuyerSignup widget
                      ),
                    );
                  },
                  child: const Text(
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
