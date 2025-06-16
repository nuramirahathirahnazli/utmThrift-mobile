// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:utmthrift_mobile/services/auth_service.dart';
import 'package:utmthrift_mobile/viewmodels/chatmessage_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/user_viewmodel.dart';

import 'package:utmthrift_mobile/views/shared/top_nav.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import 'package:utmthrift_mobile/models/item_model.dart';
import 'package:utmthrift_mobile/services/item_service.dart';
import 'package:utmthrift_mobile/views/items/item_card_explore.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final ItemService _itemService = ItemService();

  List<Item> _items = [];
  Set<int> _favoriteItemIds = {};
  bool _isLoading = false;
  DateTime? _lastFavoriteTap;

  int? _userId;

  Timer? _debounce;
  
  final List<String> _categories = [
    "Women Clothes", "Books & Notes", "Electronics", "Beauty & Health",
    "Men Clothes", "Furniture", "Sports & Outdoors", "Toys & Games",
    "Home Appliances", "Jewelry & Accessories", "Pet Supplies"
  ];

  final List<String> _conditions = [
    'Brand New', 'Like New', 'Lightly Used', 'Well Used', 'Heavily Used',
  ];

  final List<String> _priceRanges = [
    'Under RM50', 'RM50 - RM100', 'RM100 - RM200', 'Above RM200',
  ];

  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedPriceRange;

  Future<void> _cacheFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites', 
      _favoriteItemIds.map((id) => id.toString()).toList(),
    );
  }

  Future<void> _loadCachedFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favoriteItemIds = cached.map((id) => int.parse(id)).toSet();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadCachedFavorites();
    _loadFavorites();
    

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _loadItems();
      });
    });


    _initUserAndData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      await userVM.loadUser(); 

      final chatVM = Provider.of<ChatMessageViewModel>(context, listen: false);
        chatVM.initialize(currentUserId: userVM.userId);

        if (chatVM.currentUserId != null) {
          await chatVM.fetchUnreadMessagesForSeller();

          // **Fetch unread count from API for the badge**
          await chatVM.fetchUnreadMessageCount();
        } else {
          print('Error: currentUserId is null in SellerHomeScreen initState');
        }
    });
  }

  Future<void> _initUserAndData() async {
    _userId = await AuthService.getCurrentUserId();
    if (_userId == null) {
      print('No logged-in user found.');
      return;
    }

    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    final chatVM = Provider.of<ChatMessageViewModel>(context, listen: false);

    await Future.wait([
      _loadCachedFavorites(),
      _loadFavorites(),
      _loadItems(),
      cartVM.loadCartItems(_userId!),
      chatVM.fetchUnreadMessageCount(),
    ]);
  }


  Future<void> _loadFavorites() async {
    if (_userId == null) return; // user not logged in
    try {
      final Set<int> favoriteIds = await _itemService.fetchFavoriteItemIds(_userId!);
      if (mounted) {
        setState(() {
          _favoriteItemIds = favoriteIds;
        });
      }
      _cacheFavorites();
    } catch (e) {
      print('Failed to load favorites: $e');
    }
  }

  
  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Dispose debounce timer
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      setState(() => _isLoading = true);
      final searchQuery = _searchController.text.toLowerCase();
      final allItems = await _itemService.fetchAllItems();

      final filteredItems = allItems.where((item) {
        final matchesSearch =
            searchQuery.isEmpty || item.name.toLowerCase().contains(searchQuery);
        final matchesCategory =
            _selectedCategory == null || item.category == _selectedCategory;
        final matchesCondition =
            _selectedCondition == null || item.condition == _selectedCondition;
        final matchesPrice = _selectedPriceRange == null || _matchPriceRange(item.price, _selectedPriceRange!);

        return matchesSearch && matchesCategory && matchesCondition && matchesPrice;
      }).toList();

      if (mounted) {
        setState(() {
          _items = filteredItems;
        });
      }
    } catch (e) {
      print("Error loading items: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _matchPriceRange(double price, String range) {
    switch (range) {
      case 'Under RM50':
        return price < 50;
      case 'RM50 - RM100':
        return price >= 50 && price <= 100;
      case 'RM100 - RM200':
        return price > 100 && price <= 200;
      case 'Above RM200':
        return price > 200;
      default:
        return true;
    }
  }

  void _showFilterModal(BuildContext context) {
    String? tempCondition = _selectedCondition;
    String? tempPriceRange = _selectedPriceRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  const Text("Filter by", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempCondition,
                    hint: const Text("Select Condition"),
                    onChanged: (value) => setStateModal(() => tempCondition = value),
                    items: _conditions
                        .map((cond) => DropdownMenuItem(value: cond, child: Text(cond)))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: tempPriceRange,
                    hint: const Text("Select Price Range"),
                    onChanged: (value) => setStateModal(() => tempPriceRange = value),
                    items: _priceRanges
                        .map((range) => DropdownMenuItem(value: range, child: Text(range)))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCondition = null;
                            _selectedPriceRange = null;
                          });
                          Navigator.pop(context);
                          _loadItems();
                        },
                        child: const Text("Clear Filters"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedCondition = tempCondition;
                            _selectedPriceRange = tempPriceRange;
                          });
                          _loadItems();
                        },
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
    final cartViewModel = Provider.of<CartViewModel>(context);
    final chatVM = Provider.of<ChatMessageViewModel>(context);

    return Scaffold(
      appBar: TopNavBar(
        searchController: _searchController,
        onSearchSubmitted: (_) => _loadItems(),
        cartCount: cartViewModel.itemCount, // ✅ Cart count
        chatCount: chatVM.unreadCount,      // ✅ Chat unread count
        onCartPressed: () {
          Navigator.pushNamed(context, '/cartPage'); // or your cart route
        },
      ),
      drawer: const Drawer(),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: _categories.map((cat) {
                final bool selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    selectedColor: AppColors.color6,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = selected ? null : cat;
                      });
                      _loadItems();
                    },
                    backgroundColor: Colors.grey.shade200,
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showFilterModal(context),
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text("No items found."))
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: GridView.builder(
                          itemCount: _items.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return ItemCardExplore(
                              imageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : '',
                              name: item.name,
                              price: item.price,
                              condition: item.condition,
                              seller: item.seller ?? '',
                              itemId: item.id,
                              isFavorite: _favoriteItemIds.contains(item.id),
                              onFavoriteToggle: () async {
                                try {
                                  if (_lastFavoriteTap != null && 
                                      DateTime.now().difference(_lastFavoriteTap!) < const Duration(milliseconds: 500)) {
                                    return;
                                  }
                                  _lastFavoriteTap = DateTime.now();
                                  
                                  // Haptic feedback
                                  await HapticFeedback.lightImpact();
                                  
                                  // Optimistically update UI
                                  setState(() {
                                    if (_favoriteItemIds.contains(item.id)) {
                                      _favoriteItemIds.remove(item.id);
                                    } else {
                                      _favoriteItemIds.add(item.id);
                                    }
                                  });
                                  
                                  // Call API to toggle favorite
                                  await _itemService.addFavorite(_userId!, item.id);
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_favoriteItemIds.contains(item.id)
                                            ? 'Added to favorites!'
                                            : 'Removed from favorites'),
                                        duration: const Duration(seconds: 1),
                                    ),
                                    );
                                  }
                                } catch (e) {
                                  // Revert UI if API call fails
                                  if (mounted) {
                                    setState(() {
                                      if (_favoriteItemIds.contains(item.id)) {
                                        _favoriteItemIds.remove(item.id);
                                      } else {
                                        _favoriteItemIds.add(item.id);
                                      }
                                    });
                                  }
                                  print('Error toggling favorite: $e');
                                }
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}