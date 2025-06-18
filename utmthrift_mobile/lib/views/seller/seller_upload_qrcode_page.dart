// lib/views/seller/upload_qr_code_page.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utmthrift_mobile/services/order_service.dart'; // Assuming upload QR lives here

class UploadQrCodePage extends StatefulWidget {
  const UploadQrCodePage({super.key});

  @override
  State<UploadQrCodePage> createState() => _UploadQrCodePageState();
}

class _UploadQrCodePageState extends State<UploadQrCodePage> {
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _uploadQrCode() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    final success = await OrderService.uploadSellerQrCode(_selectedImage!); // You'll create this

    setState(() => _isUploading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("QR Code uploaded successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to upload QR Code")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload QR Code")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : const Text("No image selected"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text("Pick QR Image"),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadQrCode,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text("Upload QR Code"),
            ),
          ],
        ),
      ),
    );
  }
}
