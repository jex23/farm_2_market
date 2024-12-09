import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'farmer_homepage.dart';
import 'farmer_user_data.dart'; // Import the singleton for global UID storage

class FarmerSignup extends StatefulWidget {
  @override
  _FarmerSignupState createState() => _FarmerSignupState();
}

class _FarmerSignupState extends State<FarmerSignup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store the UID globally in the singleton
      UserData().uid = userCredential.user!.uid;

      // Save user details in Firestore
      await _firestore.collection('Farmers').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCredential.user!.uid,
        'createdAt': Timestamp.now(),
      });

      // Navigate to Farmer Homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FarmerHomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Image.asset(
                  'assets/first page logo.png',
                  height: 100,
                ),
                SizedBox(height: 40),
                Text(
                  'Sign Up to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF09101D),
                    fontSize: 23,
                    fontFamily: 'Source Sans Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 32),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Enter your name',
                  icon: Icons.person,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: 'Enter your phone number',
                  icon: Icons.phone,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  hintText: 'Enter your address',
                  icon: Icons.home,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  icon: Icons.email,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Re-Enter Password',
                  hintText: 'Confirm your password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 32),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _signup,
                  child: Text('Sign Up'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Already have an account? Sign in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontFamily: 'Source Sans Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x145A6CEA),
            blurRadius: 50,
            offset: Offset(12, 26),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: Color(0xFFEAEEF2)),
          ),
        ),
      ),
    );
  }
}
