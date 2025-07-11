// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/views/seller/seller_edit_item_details_page.dart';
import 'package:utmthrift_mobile/views/seller/seller_home_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class ItemDetailsPage extends StatefulWidget {
  final int itemId;

  const ItemDetailsPage({required this.itemId, super.key});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late Future<Map<String, dynamic>?> _itemFuture = Future.value(null);


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
      setState(() {
        _itemFuture = viewModel.fetchItemDetails(widget.itemId);
      });
    });
  }


  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete', style: TextStyle(color: AppColors.color10)),
        content: const Text('Are you sure you want to delete this item?'),
        backgroundColor: AppColors.base,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.color1)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.color8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
      final success = await viewModel.deleteItem(widget.itemId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Item deleted successfully'),
            backgroundColor: AppColors.color13,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          "Item Details",
          style: TextStyle(color: AppColors.base, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.color2,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: AppColors.base),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Back to Home',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _itemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.color2),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.color8)),
            );
          }

          final item = snapshot.data;
          if (item == null) {
            return const Center(
              child: Text('No item details available', style: TextStyle(color: AppColors.color10)),
            );
          }

          final images = item['images'] is List ? List<String>.from(item['images']) : [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Details Card
                Card(
                  color: AppColors.color12,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? 'Unknown Item',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.color10,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          icon: Icons.category,
                          label: 'Category',
                          value: item['category']?['name'] ?? 'Not available',
                        ),
                        _buildDetailRow(
                          icon: Icons.attach_money,
                          label: 'Price',
                          value: 'RM ${num.tryParse(item['price'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                          valueStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.color1,
                          ),
                        ),
                        _buildDetailRow(
                          icon: Icons.assessment,
                          label: 'Condition',
                          value: item['condition'] ?? 'Unknown',
                        ),
                        _buildDetailRow(
                          icon: Icons.description,
                          label: 'Description',
                          value: item['description'] ?? 'No description available',
                          isInline: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Images Section
                const Text(
                  'Item Images',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.color2),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: images.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final imageUrl = Uri.decodeFull(images[index]);
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 180,
                                    height: 180,
                                    color: AppColors.color9,
                                    child: const Icon(Icons.broken_image, size: 50, color: AppColors.color3),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.color11,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "No images available",
                              style: TextStyle(color: AppColors.color2),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final itemData = await _itemFuture;
                  if (itemData != null) {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerEditItemDetailsPage(item: itemData),
                      ),
                    );
                    if (updated == true && mounted) {
                      final viewModel = Provider.of<ItemViewModel>(context, listen: false);
                      setState(() {
                        _itemFuture = viewModel.fetchItemDetails(widget.itemId);
                      });
                    }
                  }
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text("Edit Item", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color1,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deleteItem,
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text("Delete Item", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color8,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
    bool isInline = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.color2),
          const SizedBox(width: 12),
          Expanded(
            child: isInline
                ? Row(
                    children: [
                      Text(
                        '$label: ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.color10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          value,
                          style: valueStyle ??
                              const TextStyle(fontSize: 16, color: AppColors.color10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$label:',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.color10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: valueStyle ??
                            const TextStyle(fontSize: 16, color: AppColors.color10),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
