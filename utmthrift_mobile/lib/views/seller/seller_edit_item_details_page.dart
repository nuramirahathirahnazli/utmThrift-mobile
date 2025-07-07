// ignore_for_file: library_private_types_in_public_api, avoid_print, unnecessary_nullable_for_final_variable_declarations

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/services/item_service.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class SellerEditItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const SellerEditItemDetailsPage({required this.item, super.key});

  @override
  _SellerEditItemDetailsPageState createState() =>
      _SellerEditItemDetailsPageState();
}

class _SellerEditItemDetailsPageState extends State<SellerEditItemDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  String _condition = 'Used';
  int? _selectedCategoryId;
  List<XFile>? _pickedImages;
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  final List<String> _conditionOptions = [
    'Brand New',
    'Like New',
    'Lightly Used',
    'Well Used',
    'Heavily Used'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.item['name'] ?? '');
    _priceController = TextEditingController(
        text: widget.item['price']?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.item['description'] ?? '');
    _condition = widget.item['condition'] ?? 'Used';
    _selectedCategoryId = widget.item['category']?['id'];
    _existingImageUrls = List<String>.from(widget.item['images'] ?? []);
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
      viewModel.fetchCategories().catchError((e) {
        _showErrorSnackbar('Failed to fetch categories: $e');
      });
      _loadItemDetails();
    });
  }

  Future<void> _loadItemDetails() async {
    try {
      final itemId = widget.item['id'];
      final item = await ItemService().fetchItemDetails(itemId);
      if (mounted) {
        setState(() {
          _existingImageUrls = List<String>.from(item['images'] ?? []);
        });
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar('Failed to load item details: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.color8,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await ImagePicker().pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() => _pickedImages = images);
    }
  }

  Future<void> _updateItem() async {
    if (_selectedCategoryId == null) {
      _showErrorSnackbar('Please select a category');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
      await viewModel.updateItem(
        itemId: widget.item['id'],
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        condition: _condition,
        categoryId: _selectedCategoryId!,
        images: _pickedImages,
        existingImages: _existingImageUrls,
      );

      if (!mounted) return;

      if (viewModel.errorMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item updated successfully!'),
            backgroundColor: AppColors.color2,
          ),
        );
        Navigator.pop(context, true);
      } else {
        _showErrorSnackbar('Update failed: ${viewModel.errorMessage}');
      }
    } catch (e) {
      _showErrorSnackbar('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildConditionDropdown() {
    return DropdownButtonFormField<String>(
      value: _condition,
      decoration: appInputDecoration(
        labelText: 'Condition',
        prefixIcon: Icons.construction,
      ),
      dropdownColor: AppColors.base,
      style: const TextStyle(color: AppColors.color10),
      items: _conditionOptions
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: const TextStyle(color: AppColors.color10)),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _condition = value);
      },
    );
  }

  Widget _buildCategoryDropdown(List<dynamic> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.color2),
      );
    }
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: appInputDecoration(
        labelText: 'Category',
        prefixIcon: Icons.category,
      ),
      dropdownColor: AppColors.base,
      style: const TextStyle(color: AppColors.color10),
      items: categories
          .map((cat) => DropdownMenuItem<int>(
                value: cat['id'],
                child: Text(
                  cat['name'],
                  style: const TextStyle(color: AppColors.color10),
                ),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedCategoryId = value);
      },
      hint: Text(
        'Select a category',
        style: TextStyle(color: AppColors.color10.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildImagePreview() {
    final images = _pickedImages ?? [];
    final allImages = [..._existingImageUrls, ...images.map((e) => e.path)];

    if (allImages.isEmpty) {
      return Column(
        children: [
          sectionHeader('Images'),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.color12.withOpacity(0.3),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, size: 40, color: AppColors.color2),
                  const SizedBox(height: 8),
                  Text(
                    'No images selected',
                    style: TextStyle(color: AppColors.color10.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeader('Images'),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allImages.length,
            itemBuilder: (_, index) {
              final isNewImage = index >= _existingImageUrls.length;
              final image = allImages[index];

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.color12,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isNewImage
                            ? kIsWeb
                                ? Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  )
                                : Image.file(
                                    File(image),
                                    fit: BoxFit.cover,
                                  )
                            : Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                      ),
                    ),
                    if (isNewImage)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => setState(() => _pickedImages!.removeAt(
                              index - _existingImageUrls.length)),
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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ItemViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          'Edit Item',
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
      body: viewModel.isLoading || _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.color2))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextFormField(
                      controller: _nameController,
                      label: 'Item Name',
                      icon: Icons.shopping_bag,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _priceController,
                      label: 'Price',
                      icon: Icons.attach_money,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required field';
                        if (double.tryParse(value!) == null) {
                          return 'Enter valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      maxLines: 4,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildConditionDropdown(),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(viewModel.categories),
                    const SizedBox(height: 24),
                    _buildImagePreview(),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_a_photo, color: AppColors.base),
                      label: const Text(
                        "Add More Images",
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
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.color2,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Update Item',
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
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: appInputDecoration(
        labelText: label,
        prefixIcon: icon,
      ),
      style: const TextStyle(color: AppColors.color10),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}

// Reusable components from previous beautification
InputDecoration appInputDecoration({
  required String labelText,
  required IconData prefixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
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
    filled: true,
    fillColor: AppColors.base.withOpacity(0.05),
    prefixIcon: Icon(prefixIcon, color: AppColors.color2),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
  );
}

Widget sectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.color2,
      ),
    ),
  );
}