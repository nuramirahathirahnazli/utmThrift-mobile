// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Now re-enabled for real devices
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/profile_viewmodel.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb check

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  String? _selectedGender;
  String? _selectedUserRole;
  File? _image;
  String? cloudinaryUrl; // Holds Cloudinary image URL

  final picker = ImagePicker(); // Image Picker for real devices

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();

    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    profileVM.fetchUserProfile().then((_) {
      if (mounted) {
        setState(() {
          _nameController.text = profileVM.user?.name ?? "";
          _phoneController.text = profileVM.user?.contact ?? "";
          _locationController.text = profileVM.user?.location ?? "";
          _selectedGender = profileVM.user?.gender ?? "Male";
          _selectedUserRole = profileVM.user?.userRole ?? "Student";
          cloudinaryUrl = profileVM.user?.profilePicture;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    print("Camera icon clicked");
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Web: use XFile and read as bytes
        var bytes = await pickedFile.readAsBytes();
        setState(() {
          _image = null; // Web doesn't use File for preview
        });
        await uploadImageToCloudinaryWeb(bytes, pickedFile.name);
      } else {
        // Mobile: use File directly
        File imageFile = File(pickedFile.path);
        setState(() {
          _image = imageFile;
        });
        await uploadImageToCloudinaryMobile(imageFile);
      }
    } else {
      print("No image selected");
    }
  }


  Future<void> uploadImageToCloudinaryWeb(Uint8List bytes, String filename) async {
    String cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dvod7bmal/image/upload';
    const uploadPreset = 'flutter_unsigned';

    final mimeType = lookupMimeType(filename) ?? 'image/jpeg';

    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
    request.fields['upload_preset'] = uploadPreset;

    final imageFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(imageFile);

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        setState(() {
          this.cloudinaryUrl = data['secure_url'];
        });
        print("Image uploaded to Cloudinary (Web): ${data['secure_url']}");
      } else {
        print('Web upload failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image (Web): $e');
    }
  }

  Future<void> uploadImageToCloudinaryMobile(File image) async {
    String cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dvod7bmal/image/upload';
    const uploadPreset = 'flutter_unsigned';

    final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';

    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
    request.fields['upload_preset'] = uploadPreset;

    final imageFile = await http.MultipartFile.fromPath(
      'file',
      image.path,
      contentType: MediaType.parse(mimeType),
    );

    request.files.add(imageFile);

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        setState(() {
          this.cloudinaryUrl = data['secure_url'];
        });
        print("Image uploaded to Cloudinary (Mobile): ${data['secure_url']}");
      } else {
        print('Mobile upload failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image (Mobile): $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final user = profileVM.user;

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.color3,
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 20),
              _buildTextField("Name", _nameController),
              _buildTextField("Phone", _phoneController),
              _buildReadOnlyField("Email", user?.email ?? "N/A"),
              _buildReadOnlyField("Matric Number", user?.matric ?? "N/A"),
              _buildDropdownField("Gender", ["Male", "Female"], _selectedGender, (value) {
                setState(() => _selectedGender = value);
              }),
              _buildTextField("Location (only shortform of college)", _locationController),
              _buildDropdownField("User Role", ["Student", "Lecturer"], _selectedUserRole, (value) {
                setState(() => _selectedUserRole = value);
              }),
              _buildReadOnlyField("User Type", user?.userType ?? "N/A"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.color3),
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _image != null
                ? FileImage(_image!)
                : (cloudinaryUrl != null
                    ? NetworkImage(cloudinaryUrl!) as ImageProvider
                    : const AssetImage('assets/images/profile_pic.png')),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.black),
              onPressed: pickImage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    if (selectedValue == null || !items.contains(selectedValue)) {
      selectedValue = items.first;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        items: items.toSet().map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

    print("Saving profile:");
    print("Image URL: $cloudinaryUrl");

    bool success = await profileVM.updateProfile(
      name: _nameController.text.trim(),
      contact: _phoneController.text.trim(),
      email: profileVM.user?.email ?? "",
      gender: _selectedGender ?? "Male",
      location: _locationController.text.trim(),
      userRole: _selectedUserRole ?? "Student",
      userType: profileVM.user?.userType ?? "Buyer",
      imageFile: _image, 
    );


    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile. Try again!")),
      );
    }
  }
}
