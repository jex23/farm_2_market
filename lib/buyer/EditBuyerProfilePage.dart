import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'buyer_user_data.dart'; // Your BuyerUserData class for accessing the buyer's UID

class EditBuyerProfilePage extends StatefulWidget {
  final Map<String, dynamic> buyerData;

  EditBuyerProfilePage({required this.buyerData});

  @override
  _EditBuyerProfilePageState createState() => _EditBuyerProfilePageState();
}

class _EditBuyerProfilePageState extends State<EditBuyerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  File? _selectedImage; // To hold the selected image

  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.buyerData['name']);
    _emailController = TextEditingController(text: widget.buyerData['email']);
    _phoneController = TextEditingController(text: widget.buyerData['phone']);
    _addressController = TextEditingController(text: widget.buyerData['address']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Store the selected image
      });
    }
  }

  // Function to upload the image to Firebase Storage
  Future<String?> _uploadImage(File image) async {
    try {
      // Create a unique file name
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('buyer_photos/$fileName');

      // Upload the file
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      throw e;
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      String? photoUrl = widget.buyerData['photoUrl']; // Default photo URL

      // If a new image is selected, upload it to Firebase Storage
      if (_selectedImage != null) {
        photoUrl = await _uploadImage(_selectedImage!); // Get the URL of the uploaded image
      }

      try {
        await FirebaseFirestore.instance
            .collection('Buyers')
            .doc(BuyerUserData().uid) // Use BuyerUserData singleton for UID
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'photoUrl': photoUrl ?? widget.buyerData['photoUrl'], // Keep existing photo URL if none is uploaded
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        Navigator.pop(context); // Go back to the previous page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextFormField(_nameController, 'Name'),

              _buildTextFormField(_phoneController, 'Phone'),
              _buildTextFormField(_addressController, 'Address'),

              // Button to pick an image (optional)
              _selectedImage == null
                  ? ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Pick an Image'),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.file(
                  _selectedImage!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),

              Spacer(),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for building TextFormField
  Widget _buildTextFormField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.green),
          ),
        ),
        validator: (value) =>
        value!.isEmpty ? '$label cannot be empty' : null,
      ),
    );
  }
}
