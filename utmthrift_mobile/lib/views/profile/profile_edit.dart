// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/profile_viewmodel.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';

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
  String? cloudinaryUrl;
  final picker = ImagePicker();

  // Define dropdown options
  final List<String> _genderOptions = ["Male", "Female"];
  final List<String> _userRoleOptions = ["Student", "Lecturer"];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    _loadInitialProfileData();
  }

  Future<void> _loadInitialProfileData() async {
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    await profileVM.fetchUserProfile();
    if (mounted) {
      setState(() {
        _nameController.text = profileVM.user?.name ?? "";
        _phoneController.text = profileVM.user?.contact ?? "";
        _locationController.text = profileVM.user?.location ?? "";
        // Ensure selected values are in the options list
        _selectedGender = _genderOptions.contains(profileVM.user?.gender)
            ? profileVM.user?.gender
            : _genderOptions.first;
        _selectedUserRole = _userRoleOptions.contains(profileVM.user?.userRole)
            ? profileVM.user?.userRole
            : _userRoleOptions.first;
        cloudinaryUrl = profileVM.user?.profilePicture;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        var bytes = await pickedFile.readAsBytes();
        setState(() => _image = null);
        await uploadImageToCloudinaryWeb(bytes, pickedFile.name);
      } else {
        File imageFile = File(pickedFile.path);
        setState(() => _image = imageFile);
        await uploadImageToCloudinaryMobile(imageFile);
      }
    }
  }

  Future<void> uploadImageToCloudinaryWeb(Uint8List bytes, String filename) async {
    try {
      final mimeType = lookupMimeType(filename) ?? 'image/jpeg';
      final request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://api.cloudinary.com/v1_1/dvod7bmal/image/upload')
      );
      request.fields['upload_preset'] = 'flutter_unsigned';
      request.files.add(http.MultipartFile.fromBytes(
        'file', bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        setState(() => cloudinaryUrl = data['secure_url']);
      }
    } catch (e) {
      print('Error uploading image (Web): $e');
    }
  }

  Future<void> uploadImageToCloudinaryMobile(File image) async {
    try {
      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
      final request = http.MultipartRequest(
        'POST', 
        Uri.parse('https://api.cloudinary.com/v1_1/dvod7bmal/image/upload')
      );
      request.fields['upload_preset'] = 'flutter_unsigned';
      request.files.add(await http.MultipartFile.fromPath(
        'file', image.path,
        contentType: MediaType.parse(mimeType),
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        setState(() => cloudinaryUrl = data['secure_url']);
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
        backgroundColor: AppColors.color2, // Maroon app bar
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.base),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.color12, // Light yellow background
                      border: Border.all(
                        color: AppColors.color3, // Light pink border
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: _image != null
                          ? Image.file(_image!, fit: BoxFit.cover)
                          : (cloudinaryUrl != null
                              ? Image.network(cloudinaryUrl!, fit: BoxFit.cover)
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.color2, // Maroon icon
                                )),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.color2, // Maroon background
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.base, // Cream border
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        color: AppColors.base, // Cream icon
                        onPressed: pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Personal Information
              _buildSectionHeader("Personal Information"),
              _buildTextField("Name", _nameController, Icons.person),
              _buildTextField("Phone", _phoneController, Icons.phone),
              _buildReadOnlyField("Email", user?.email ?? "N/A", Icons.email),
              _buildReadOnlyField(
                "Matric Number", 
                user?.matric ?? "N/A", 
                Icons.badge
              ),
              const SizedBox(height: 16),

              // Additional Information
              _buildSectionHeader("Additional Information"),
              _buildDropdownField(
                "Gender", 
                ["Male", "Female"], 
                _selectedGender, 
                (value) => setState(() => _selectedGender = value),
                Icons.transgender,
              ),
              _buildTextField(
                "Location (college shortform)", 
                _locationController,
                Icons.location_on,
              ),
              _buildDropdownField(
                "User Role", 
                ["Student", "Lecturer"], 
                _selectedUserRole, 
                (value) => setState(() => _selectedUserRole = value),
                Icons.work,
              ),
              _buildReadOnlyField(
                "User Type", 
                user?.userType ?? "N/A", 
                Icons.category
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color2, // Maroon button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.base, // Cream text
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.color2, // Maroon text
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.color2),
          filled: true,
          fillColor: AppColors.color12, // Light yellow background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      initialValue: value,
      readOnly: true,
      style: const TextStyle(color: AppColors.color10), // keep text normal
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.color10.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: AppColors.color2),
        filled: true,
        fillColor: AppColors.color10.withOpacity(0.06), // very soft background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    ),
  );
}

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    // Ensure selectedValue is valid or use first item
    final validValue = items.contains(selectedValue) ? selectedValue : items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: validValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.color2),
          filled: true,
          fillColor: AppColors.color12,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
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
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: AppColors.color13, // Green success
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update profile. Try again!"),
          backgroundColor: AppColors.color8, // Red error
        ),
      );
    }
  }
}