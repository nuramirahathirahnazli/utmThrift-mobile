// lib/views/seller/upload_qr_code_page.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utmthrift_mobile/services/order_service.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

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

    final success = await OrderService.uploadSellerQrCode(_selectedImage!);

    setState(() => _isUploading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR Code uploaded successfully"),
          backgroundColor: AppColors.color2,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to upload QR Code"),
          backgroundColor: AppColors.color8,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          "Upload QR Code",
          style: TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.color2,
        iconTheme: const IconThemeData(color: AppColors.base),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedImage != null)
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.color12.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.color2.withOpacity(0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 100,
                          color: AppColors.color2.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No QR Code selected",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.color10.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image, color: AppColors.base),
              label: const Text(
                "Select QR Code Image",
                style: TextStyle(color: AppColors.base),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.color2,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadQrCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedImage == null
                    ? AppColors.color2.withOpacity(0.5)
                    : AppColors.color2,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Upload QR Code",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.base,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}