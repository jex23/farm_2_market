import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'farmer_user_data.dart';

class FarmerCreatePost extends StatefulWidget {
  @override
  _FarmerCreatePostState createState() => _FarmerCreatePostState();
}

class _FarmerCreatePostState extends State<FarmerCreatePost> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceStartController = TextEditingController();
  final TextEditingController _priceEndController = TextEditingController();
  final TextEditingController _minOrderController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Category dropdown
  String? _selectedCategory;
  final List<String> _categories = ['Rice', 'Fruits', 'Vegetable', 'Meat & Chicken'];

  // Images
  List<File> _selectedImages = [];

  bool _isLoading = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _uploadPost() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = UserData().uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    List<String> imageUrls = [];

    if (_selectedImages.isNotEmpty) {
      for (var image in _selectedImages) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('farmer_posts/${DateTime.now().toIso8601String()}-${image.hashCode}');
        await storageRef.putFile(image);
        String downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
    }

    final postData = {
      'title': _titleController.text.trim(),
      'priceStart': double.parse(_priceStartController.text.trim()),
      'priceEnd': double.parse(_priceEndController.text.trim()),
      'minOrder': _minOrderController.text.trim(),
      'description': _descriptionController.text.trim(),
      'address': _addressController.text.trim(),
      'category': _selectedCategory,
      'uid': userId,
      'imageUrls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('FarmerPost').add(postData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post created successfully')),
    );

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x145A6CEA),
            blurRadius: 20,
            offset: Offset(0, 10),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.post_add,
                    size: 100,
                    color: Colors.green,
                  ),
                  Text(
                    'Create Your Post',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF09101D),
                      fontSize: 23,
                      fontFamily: 'Source Sans Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Title',
                    hintText: 'Enter the post title',
                    icon: Icons.title,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Category is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _priceStartController,
                    label: 'Start Price',
                    hintText: 'Enter the starting price',
                    icon: Icons.attach_money,
                  ),
                  _buildTextField(
                    controller: _priceEndController,
                    label: 'End Price',
                    hintText: 'Enter the ending price',
                    icon: Icons.money_off,
                  ),
                  _buildTextField(
                    controller: _minOrderController,
                    label: 'Minimum Order Quantity',
                    hintText: 'Enter the minimum order quantity',
                    icon: Icons.shopping_cart,
                  ),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hintText: 'Enter a description',
                    icon: Icons.description,
                  ),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    hintText: 'Enter your address',
                    icon: Icons.location_on,
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: Icon(Icons.image),
                    label: Text('Select Images'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 55),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  if (_selectedImages.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedImages.map((image) {
                        return Image.file(
                          image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _uploadPost,
                    child: Text('Post'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 55),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
