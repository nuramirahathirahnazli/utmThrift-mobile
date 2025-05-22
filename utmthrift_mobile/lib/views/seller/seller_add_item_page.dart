// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_nullable_for_final_variable_declarations, library_private_types_in_public_api, unnecessary_import

import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/views/seller/seller_item_details_page.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  String productName = '';
  String category = '';
  String description = '';
  double price = 0.0;
  String condition = 'Brand New';

  final ImagePicker _picker = ImagePicker();
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
          const SnackBar(content: Text('You can only select up to 5 images.')),
        );
        return;
      }
      setState(() {
        selectedImages.addAll(images);
      });
    }
  }

 /// Store images differently for web and mobile
  Future<List<String>> storeImages() async {
    List<String> imagePaths = [];

    if (kIsWeb) {
      // On Web, we send image bytes, so no need to save files locally.
      // Just encode bytes as base64 string (or pass bytes separately)
      // Here we just prepare the base64 strings for demonstration if needed
      for (var image in selectedImages) {
        final bytes = await image.readAsBytes();
        imagePaths.add(base64Encode(bytes));
      }
    } else {
      // On Mobile, save image files locally and return their paths
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
          print('Error saving image: $e');
        }
      }
    }

    return imagePaths;
  }


  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
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

      // For web, we prepare image bytes
      List<Uint8List>? imageBytes;
      if (kIsWeb) {
        imageBytes = [];
        for (var image in selectedImages) {
          final bytes = await image.readAsBytes();
          imageBytes.add(bytes);
        }
      }

      final itemViewModel = Provider.of<ItemViewModel>(context, listen: false);
      final addedItem = await itemViewModel.addItem(
        name: productName,
        categoryId: int.parse(category),
        description: description,
        price: price,
        condition: condition,
        imagePaths: kIsWeb ? null : imagePaths,  // pass null for web
        imageBytes: kIsWeb ? imageBytes : null,   // pass bytes only for web
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
      appBar: AppBar(
        title: const Text('Add New Item'),
        elevation: 0,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Consumer<ItemViewModel>(
            builder: (context, model, _) {
              if (model.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (model.errorMessage.isNotEmpty) {
                return Center(child: Text('Error: ${model.errorMessage}'));
              }

              final categories = model.categories;

              return ListView(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    onSaved: (value) => productName = value ?? '',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter a product name' : null,
                  ),
                  DropdownButtonFormField<String>(
                    items: categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'].toString(),
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                      });
                    },
                    hint: const Text('Select a category'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please select a category' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) => description = value ?? '',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter a description' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => price = double.tryParse(value ?? '') ?? 0.0,
                    validator: (value) {
                      final priceValue = double.tryParse(value ?? '');
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      } else if (priceValue == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Condition'),
                    value: condition,
                    onChanged: (value) => setState(() => condition = value ?? 'Brand New'),
                    items: [
                      'Brand New',
                      'Like New',
                      'Lightly Used',
                      'Well Used',
                      'Heavily Used'
                    ]
                        .map((cond) => DropdownMenuItem(
                              value: cond,
                              child: Text(cond),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text("Images (max 5):"),
                  ElevatedButton.icon(
                    onPressed: pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text("Add Images"),
                  ),
                  const SizedBox(height: 10),
                  if (selectedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                child: kIsWeb
                                    ? FutureBuilder<Uint8List>(
                                        future: selectedImages[index].readAsBytes(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Center(
                                                child: CircularProgressIndicator());
                                          }
                                          return Image.memory(
                                            snapshot.data!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.file(
                                        io.File(selectedImages[index].path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => removeImage(index),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : submitForm,
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sell This Item'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

