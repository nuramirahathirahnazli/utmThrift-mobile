// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/sellerapplication_viewmodel.dart';
import 'package:file_picker/file_picker.dart';

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
          const SnackBar(content: Text('Application submitted successfully!')),
        );
        Navigator.pop(context); // go back to profile
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage ?? 'Failed to submit')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SellerApplicationViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Apply to Become a Seller")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _storeNameController,
                decoration: const InputDecoration(labelText: "Store Name"),
                validator: (value) => value == null || value.isEmpty ? 'Enter your store name' : null,
              ),
              const SizedBox(height: 16),
              _matricCardFile == null
                  ? const Text("No file selected")
                  : Text("Selected: ${_matricCardFile!.path.split('/').last}"),
              TextButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Matric Card"),
              ),
              const SizedBox(height: 20),
              viewModel.isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Submit Application"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
