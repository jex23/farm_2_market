import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class BuyerSignup extends StatefulWidget {
  @override
  _BuyerSignupState createState() => _BuyerSignupState();
}

class _BuyerSignupState extends State<BuyerSignup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('buyer_profiles/${DateTime.now().toIso8601String()}');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

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

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      // Save user details in Firestore
      await _firestore.collection('Buyers').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCredential.user!.uid,
        'profileImage': imageUrl ?? '',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup successful')),
      );

      // Navigate back to login screen
      Navigator.pop(context);
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
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            children: [
              // Logo
              Image.asset(
                'assets/first page logo.png',
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Sign Up to Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 32),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                  backgroundColor: Colors.green,
                ),
              ),
              SizedBox(height: 20),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
