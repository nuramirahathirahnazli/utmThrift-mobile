// ignore_for_file: avoid_print, library_private_types_in_public_api

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
    setState(() {
      isLoading = true;
    });

    try {
      final items = await _itemService.fetchAllFavouritedItems(widget.favoriteItemIds.toList());
      setState(() {
        favoriteItems = items;
        filteredItems = items;
        // Debug: Print categories of all items
        print('Loaded items with categories: ${items.map((i) => i.category).toList()}');
      });
    } catch (e) {
      print('Failed to load favorite items: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
      
      // Debug: Print filtered items
      print('Filtered items: ${filteredItems.length}');
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
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filterType == 'Category')
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: AppColors.base,
                      hint: const Text("Select Category"),
                      onChanged: (value) => setStateModal(() => _selectedCategory = value),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                  cat,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ))
                          .toList(),
                    )
                  else if (filterType == 'Condition')
                    DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      dropdownColor: AppColors.base,
                      hint: const Text("Select Condition"),
                      onChanged: (value) => setStateModal(() => _selectedCondition = value),
                      items: _conditions
                          .map((cond) => DropdownMenuItem(
                                value: cond,
                                child: Text(
                                  cond,
                                  style: const TextStyle(color: Colors.black),
                                ),
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
                          style: TextStyle(color: AppColors.color3),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedFilter = filterType;
                          });
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.color3,
                        ),
                        child: const Text("Apply"),
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
      appBar: AppBar(
        title: const Text(
          'My Likes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.color3, AppColors.color3.withOpacity(0.8)], // Fixed gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.base,
        ),
        child: Column(
          children: [
            // Filter selection chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: _filterOptions.map((filter) {
                  final bool selected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      selectedColor: AppColors.color3,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                      ),
                      onSelected: (_) {
                        if (filter == 'All') {
                          _resetFilters();
                        } else {
                          _showFilterModal(context, filter);
                        }
                      },
                      backgroundColor: Colors.grey.shade200,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Active filter indicator
            if (_selectedCategory != null || _selectedCondition != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    if (_selectedCategory != null)
                      Chip(
                        label: Text(_selectedCategory!),
                        backgroundColor: AppColors.color3.withOpacity(0.2),
                        deleteIconColor: AppColors.color3,
                        onDeleted: () {
                          setState(() {
                            _selectedCategory = null;
                          });
                          _applyFilters();
                        },
                      ),
                    if (_selectedCondition != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Chip(
                          label: Text(_selectedCondition!),
                          backgroundColor: AppColors.color3.withOpacity(0.2),
                          deleteIconColor: AppColors.color3,
                          onDeleted: () {
                            setState(() {
                              _selectedCondition = null;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            
            // Items grid
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.color3),
                        strokeWidth: 4,
                      ),
                    )
                  : filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter == 'All'
                                    ? 'No Liked Items Yet'
                                    : 'No Matching Liked Items',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFilter == 'All'
                                    ? 'Start exploring and like items to see them here!'
                                    : 'Try changing your filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadFavoriteItems,
                          color: AppColors.color3,
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
      ),
      floatingActionButton: filteredItems.isNotEmpty
          ? FloatingActionButton(
              onPressed: _loadFavoriteItems,
              backgroundColor: AppColors.color3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.refresh, color: Colors.white),
            )
          : null,
    );
  }
}