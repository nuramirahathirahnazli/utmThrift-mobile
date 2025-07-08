// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/sellerapplication_viewmodel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class SellerApplicationPage extends StatefulWidget {
  const SellerApplicationPage({super.key});

  @override
  State<SellerApplicationPage> createState() => _SellerApplicationPageState();
}

class _SellerApplicationPageState extends State<SellerApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _storeNameController = TextEditingController();
  File? _matricCardFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _matricCardFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _matricCardFile != null) {
      final viewModel = Provider.of<SellerApplicationViewModel>(context, listen: false);

      final success = await viewModel.applySeller(
        _storeNameController.text,
        _matricCardFile!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Application submitted successfully!'),
            backgroundColor: AppColors.color13, // Green success color
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Failed to submit application'),
            backgroundColor: AppColors.color4, // Red error color
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else if (_matricCardFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your matric card'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SellerApplicationViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Become a Seller',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.color2, // Maroon app bar
        foregroundColor: AppColors.base, // Light text
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.base,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Store Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color10.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your unique store identity',
                style: TextStyle(
                  color: AppColors.color10.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              // Store Name Field
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: "Store Name",
                  labelStyle: const TextStyle(color: AppColors.color10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.color3),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.color2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(color: AppColors.color10),
                validator: (value) => value == null || value.isEmpty 
                    ? 'Please enter your store name' 
                    : null,
              ),
              
              const SizedBox(height: 32),
              
              // Matric Card Upload Section
              Text(
                'Verification Document',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color10.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a clear photo/scan of your matric card',
                style: TextStyle(
                  color: AppColors.color10.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              // File Upload Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.color3.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _pickFile,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          _matricCardFile == null 
                              ? Icons.cloud_upload_outlined 
                              : Icons.check_circle_outline,
                          size: 48,
                          color: _matricCardFile == null 
                              ? AppColors.color3 
                              : AppColors.color13,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _matricCardFile == null
                              ? 'Tap to upload matric card'
                              : 'File selected',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.color10,
                          ),
                        ),
                        if (_matricCardFile != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _matricCardFile!.path.split('/').last,
                            style: TextStyle(
                              color: AppColors.color10.withOpacity(0.6),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'JPG, PNG or PDF (Max 5MB)',
                          style: TextStyle(
                            color: AppColors.color10.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color2, // Maroon button
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: viewModel.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'SUBMIT APPLICATION',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.white,
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
}