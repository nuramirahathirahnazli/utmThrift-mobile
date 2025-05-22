// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/services/item_service.dart';

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

    _nameController = TextEditingController(text: widget.item['name'] ?? '');
    _priceController = TextEditingController(
        text: widget.item['price']?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.item['description'] ?? '');
    _condition = widget.item['condition'] ?? 'Used';
    _selectedCategoryId = widget.item['category_id'];
    _existingImageUrls = List<String>.from(widget.item['images'] ?? []);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
      viewModel.fetchCategories().then((_) {
        print('DEBUG: Categories fetched: ${viewModel.categories}');
      }).catchError((e) {
        print('ERROR: Failed to fetch categories - $e');
      });

      _loadItemDetails();
    });
  }

  Future<void> _loadItemDetails() async {
    try {
      final itemId = widget.item['id'];
      final item = await ItemService().fetchItemDetails(itemId);
      setState(() {
        _existingImageUrls = List<String>.from(item['images'] ?? []);
      });
    } catch (e) {
      print('ERROR: Failed to load item details - $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _pickedImages = images;
      });
    }
  }

  Future<void> _updateItem() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
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
      );

      if (!mounted) return;

      if (viewModel.errorMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${viewModel.errorMessage}')),
        );
      }
    } catch (e) {
      print('ERROR during update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildConditionDropdown() {
    return DropdownButtonFormField<String>(
      value: _condition,
      decoration: const InputDecoration(labelText: 'Condition'),
      items: _conditionOptions
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _condition = value);
        }
      },
    );
  }

  Widget _buildCategoryDropdown(List<dynamic> categories) {
    if (categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(labelText: 'Category'),
      items: categories
          .map((cat) => DropdownMenuItem<int>(
                value: cat['id'],
                child: Text(cat['name']),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategoryId = value);
        }
      },
    );
  }

  Widget _buildImagePreview() {
    final images = _pickedImages ?? [];

    if (images.isNotEmpty) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (_, i) {
            if (kIsWeb) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.network(
                  images[i].path,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.file(
                  File(images[i].path),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              );
            }
          },
        ),
      );
    } else if (_existingImageUrls.isNotEmpty) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _existingImageUrls.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.network(
              _existingImageUrls[i],
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ItemViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: viewModel.isLoading || _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  _buildConditionDropdown(),
                  const SizedBox(height: 12),
                  _buildCategoryDropdown(viewModel.categories),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: const Text('Pick Images'),
                  ),
                  const SizedBox(height: 8),
                  _buildImagePreview(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateItem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Update Item',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
