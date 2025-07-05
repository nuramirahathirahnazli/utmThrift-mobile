// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/item_model.dart';
import 'package:utmthrift_mobile/services/item_service.dart';
import 'package:utmthrift_mobile/views/items/item_card_explore.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';

class MyLikesPage extends StatefulWidget {
  final int userId;
  final Set<int> favoriteItemIds;
  final Function(int) onFavoriteToggle;

  const MyLikesPage({
    super.key,
    required this.userId,
    required this.favoriteItemIds,
    required this.onFavoriteToggle,
  });

  @override
  _MyLikesPageState createState() => _MyLikesPageState();
}

class _MyLikesPageState extends State<MyLikesPage> {
  List<Item> favoriteItems = [];
  List<Item> filteredItems = [];
  bool isLoading = true;
  final ItemService _itemService = ItemService();

  // Filter variables
  String _selectedFilter = 'All';
  String? _selectedCategory;
  String? _selectedCondition;

  final List<String> _filterOptions = ['All', 'Category', 'Condition'];
  final List<String> _categories = [
    "Women Clothes", "Books & Notes", "Electronics", "Beauty & Health",
    "Men Clothes", "Furniture", "Sports & Outdoors", "Toys & Games",
    "Home Appliances", "Jewelry & Accessories", "Pet Supplies"
  ];
  final List<String> _conditions = [
    'Brand New', 'Like New', 'Lightly Used', 'Well Used', 'Heavily Used',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavoriteItems();
  }

  Future<void> _loadFavoriteItems() async {
    setState(() => isLoading = true);
    try {
      final items = await _itemService.fetchAllFavouritedItems(widget.favoriteItemIds.toList());
      setState(() {
        favoriteItems = items;
        filteredItems = items;
      });
    } catch (e) {
      print('Failed to load favorite items: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onToggleFavorite(int itemId) {
    widget.onFavoriteToggle(itemId);
    _loadFavoriteItems();
  }

  void _applyFilters() {
    setState(() {
      filteredItems = favoriteItems.where((item) {
        bool matchesFilter = true;
        
        if (_selectedFilter == 'Category' && _selectedCategory != null) {
          matchesFilter = item.category.toLowerCase() == _selectedCategory?.toLowerCase();
        } else if (_selectedFilter == 'Condition' && _selectedCondition != null) {
          matchesFilter = item.condition.toLowerCase() == _selectedCondition?.toLowerCase();
        }
        
        return matchesFilter;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedFilter = 'All';
      _selectedCategory = null;
      _selectedCondition = null;
      filteredItems = favoriteItems;
    });
  }

  void _showFilterModal(BuildContext context, String filterType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.base,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Filter by ${filterType.toLowerCase()}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.color10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filterType == 'Category')
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: AppColors.base,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.color12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text("Select Category", style: TextStyle(color: AppColors.color10.withOpacity(0.6))),
                      onChanged: (value) => setStateModal(() => _selectedCategory = value),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat, style: const TextStyle(color: AppColors.color10)),
                              ))
                          .toList(),
                    )
                  else if (filterType == 'Condition')
                    DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      dropdownColor: AppColors.base,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.color12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text("Select Condition", style: TextStyle(color: AppColors.color10.withOpacity(0.6))),
                      onChanged: (value) => setStateModal(() => _selectedCondition = value),
                      items: _conditions
                          .map((cond) => DropdownMenuItem(
                                value: cond,
                                child: Text(cond, style: const TextStyle(color: AppColors.color10)),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetFilters();
                        },
                        child: const Text(
                          "Clear Filters",
                          style: TextStyle(color: AppColors.color2),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _selectedFilter = filterType);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.color2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Apply",
                          style: TextStyle(color: AppColors.base),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        title: const Text(
          'My Likes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.base,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.color2,
        iconTheme: const IconThemeData(color: AppColors.base),
      ),
      body: Column(
        children: [
          // Filter selection chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filterOptions.map((filter) {
                final bool selected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    selectedColor: AppColors.color2,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.base : AppColors.color10,
                    ),
                    onSelected: (_) {
                      if (filter == 'All') {
                        _resetFilters();
                      } else {
                        _showFilterModal(context, filter);
                      }
                    },
                    backgroundColor: AppColors.color12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Active filter indicator
          if (_selectedCategory != null || _selectedCondition != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedCategory != null)
                    Chip(
                      label: Text(_selectedCategory!),
                      backgroundColor: AppColors.color12,
                      labelStyle: const TextStyle(color: AppColors.color2),
                      deleteIconColor: AppColors.color2,
                      onDeleted: () {
                        setState(() => _selectedCategory = null);
                        _applyFilters();
                      },
                    ),
                  if (_selectedCondition != null)
                    Chip(
                      label: Text(_selectedCondition!),
                      backgroundColor: AppColors.color12,
                      labelStyle: const TextStyle(color: AppColors.color2),
                      deleteIconColor: AppColors.color2,
                      onDeleted: () {
                        setState(() => _selectedCondition = null);
                        _applyFilters();
                      },
                    ),
                ],
              ),
            ),
          
          // Items grid
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.color2,
                      strokeWidth: 4,
                    ),
                  )
                : filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: AppColors.color3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'All'
                                  ? 'No Liked Items Yet'
                                  : 'No Matching Liked Items',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.color10,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFilter == 'All'
                                  ? 'Start exploring and like items to see them here!'
                                  : 'Try changing your filters',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.color10.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFavoriteItems,
                        color: AppColors.color2,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return Hero(
                              tag: 'liked_item_${item.id}',
                              child: Material(
                                borderRadius: BorderRadius.circular(12),
                                elevation: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ItemCardExplore(
                                    imageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : '',
                                    name: item.name,
                                    price: item.price,
                                    condition: item.condition,
                                    seller: item.seller ?? '',
                                    itemId: item.id,
                                    isFavorite: widget.favoriteItemIds.contains(item.id),
                                    onFavoriteToggle: () => _onToggleFavorite(item.id),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: filteredItems.isNotEmpty
          ? FloatingActionButton(
              onPressed: _loadFavoriteItems,
              backgroundColor: AppColors.color2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh, color: AppColors.base),
            )
          : null,
    );
  }
}