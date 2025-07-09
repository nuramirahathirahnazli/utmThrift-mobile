// ignore_for_file: use_build_context_synchronously, unnecessary_nullable_for_final_variable_declarations, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/views/seller/seller_item_details_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  
  String productName = '';
  String category = '';
  String description = '';
  double price = 0.0;
  String condition = 'Brand New';
  List<XFile> selectedImages = [];
  bool isSubmitting = false;

 @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ItemViewModel>(context, listen: false).fetchCategories();
    });
  }

  Future<void> pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      if ((selectedImages.length + images.length) > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 5 images allowed')),
        );
        return;
      }
      setState(() => selectedImages.addAll(images));
    }
  }

  Future<List<String>> storeImages() async {
    List<String> imagePaths = [];

    if (kIsWeb) {
      for (var image in selectedImages) {
        final bytes = await image.readAsBytes();
        imagePaths.add(base64Encode(bytes));
      }
    } else {
      final directory = await getApplicationDocumentsDirectory();
      for (var image in selectedImages) {
        try {
          final fileName = image.name;
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final localImagePath = '${directory.path}/$timestamp-$fileName';
          final io.File localImage = io.File(localImagePath);
          await localImage.writeAsBytes(await image.readAsBytes());
          imagePaths.add(localImagePath);
        } catch (e) {
          debugPrint('Error saving image: $e');
        }
      }
    }

    return imagePaths;
  }

  void removeImage(int index) {
    setState(() => selectedImages.removeAt(index));
  }

  Future<void> submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    setState(() => isSubmitting = true);

    try {
      final imagePaths = await storeImages();
      if (imagePaths.isEmpty) {
        throw Exception('At least one image is required');
      }

      List<Uint8List>? imageBytes;
      if (kIsWeb) {
        imageBytes = [];
        for (var image in selectedImages) {
          imageBytes.add(await image.readAsBytes());
        }
      }

      final itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
      final addedItem = await itemViewModel.addItem(
        name: productName,
        categoryId: int.parse(category),
        description: description,
        price: price,
        condition: condition,
        imagePaths: kIsWeb ? null : imagePaths,
        imageBytes: kIsWeb ? imageBytes : null,
      );

      if (addedItem?.id != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsPage(itemId: addedItem!.id),
          ),
        );
      } else {
        throw Exception('Item creation failed: ${itemViewModel.errorMessage}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          'Add New Item',
          style: TextStyle(
            color: AppColors.base,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.color2,
        iconTheme: const IconThemeData(color: AppColors.base),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Consumer<ItemViewModel>(
            builder: (context, model, _) {
              if (model.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.color2),
                );
              }

              if (model.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    'Error: ${model.errorMessage}',
                    style: const TextStyle(
                      color: AppColors.color8,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProductNameField(),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(model.categories),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildPriceField(),
                  const SizedBox(height: 16),
                  _buildConditionDropdown(),
                  const SizedBox(height: 24),
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Name',
        labelStyle: TextStyle(color: AppColors.color10.withOpacity(0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.color2.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2, width: 2),
        ),
        prefixIcon: const Icon(Icons.shopping_bag, color: AppColors.color2),
      ),
      style: const TextStyle(color: AppColors.color10),
      onSaved: (value) => productName = value ?? '',
      validator: (value) => value == null || value.isEmpty 
          ? 'Please enter a product name' 
          : null,
    );
  }

  Widget _buildCategoryDropdown(List<dynamic> categories) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: TextStyle(color: AppColors.color10.withOpacity(0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.color2.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2, width: 2),
        ),
        prefixIcon: const Icon(Icons.category, color: AppColors.color2),
      ),
      dropdownColor: AppColors.base,
      style: const TextStyle(color: AppColors.color10),
      items: categories.map<DropdownMenuItem<String>>((category) {
        return DropdownMenuItem<String>(
          value: category['id'].toString(),
          child: Text(
            category['name'],
            style: const TextStyle(color: AppColors.color10),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => category = value!),
      hint: Text(
        'Select a category',
        style: TextStyle(color: AppColors.color10.withOpacity(0.5)),
      ),
      validator: (value) => value == null || value.isEmpty 
          ? 'Please select a category' 
          : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: TextStyle(color: AppColors.color10.withOpacity(0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.color2.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2, width: 2),
        ),
        prefixIcon: const Icon(Icons.description, color: AppColors.color2),
      ),
      style: const TextStyle(color: AppColors.color10),
      maxLines: 3,
      onSaved: (value) => description = value ?? '',
      validator: (value) => value == null || value.isEmpty 
          ? 'Please enter a description' 
          : null,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Price',
        labelStyle: TextStyle(color: AppColors.color10.withOpacity(0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.color2.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2, width: 2),
        ),
        prefixIcon: const Icon(Icons.attach_money, color: AppColors.color2),
      ),
      style: const TextStyle(color: AppColors.color10),
      keyboardType: TextInputType.number,
      onSaved: (value) => price = double.tryParse(value ?? '') ?? 0.0,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a price';
        if (double.tryParse(value) == null) return 'Enter a valid number';
        return null;
      },
    );
  }

  Widget _buildConditionDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Condition',
        labelStyle: TextStyle(color: AppColors.color10.withOpacity(0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.color2.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.color2, width: 2),
        ),
        prefixIcon: const Icon(Icons.construction, color: AppColors.color2),
      ),
      dropdownColor: AppColors.base,
      style: const TextStyle(color: AppColors.color10),
      value: condition,
      onChanged: (value) => setState(() => condition = value ?? 'Brand New'),
      items: [
        'Brand New',
        'Like New',
        'Lightly Used',
        'Well Used',
        'Heavily Used'
      ].map((cond) => DropdownMenuItem(
        value: cond,
        child: Text(
          cond,
          style: const TextStyle(color: AppColors.color10),
        ),
      )).toList(),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Images (max 5)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.color2,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: pickImages,
          icon: const Icon(Icons.add_a_photo, color: AppColors.base),
          label: const Text(
            "Add Images",
            style: TextStyle(color: AppColors.base),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.color2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.color12,
                        ),
                        child: kIsWeb
                            ? FutureBuilder<Uint8List>(
                                future: selectedImages[index].readAsBytes(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.color2),
                                    );
                                  }
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  io.File(selectedImages[index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.color8,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isSubmitting ? null : submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.color2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'Sell This Item',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.base,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}