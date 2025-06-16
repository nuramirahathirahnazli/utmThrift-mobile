

// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:utmthrift_mobile/services/auth_service.dart';
import 'package:utmthrift_mobile/services/item_service.dart';
import 'package:utmthrift_mobile/viewmodels/chatmessage_viewmodel.dart';

import 'package:utmthrift_mobile/viewmodels/event_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/user_viewmodel.dart';

import 'package:utmthrift_mobile/views/events/all_events_page.dart';
import 'package:utmthrift_mobile/views/events/event_details_page.dart';

import 'package:utmthrift_mobile/views/items/item_card_explore.dart';
import 'package:utmthrift_mobile/views/items/item_category.dart';

import 'package:utmthrift_mobile/views/pages/explore_page.dart';
import 'package:utmthrift_mobile/views/pages/my_likes_page.dart';
import 'package:utmthrift_mobile/views/pages/profile_page.dart';

import 'package:utmthrift_mobile/views/shared/bottom_nav.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import 'package:utmthrift_mobile/views/shared/hamburger_menu.dart';
import 'package:utmthrift_mobile/views/shared/top_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final String userType = 'Buyer';

  final TextEditingController _searchController = TextEditingController();
  final ItemService _itemService = ItemService();
  
  DateTime? _lastFavoriteTap;
  int? _userId;

  Set<int> _favoriteItemIds = <int>{};

  // Handle search submitted action
  void _onSearchSubmitted(String value) {
    // You can handle search here, e.g. navigate or filter items
    print('Search submitted: $value');
  }

  void _toggleFavorite(int itemId) async {
    if (_userId == null) {
      print('User not logged in, cannot toggle favorite.');
      return;
    }
  
    if (_lastFavoriteTap != null && DateTime.now().difference(_lastFavoriteTap!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastFavoriteTap = DateTime.now();

    setState(() {
      if (_favoriteItemIds.contains(itemId)) {
        _favoriteItemIds.remove(itemId);
      } else {
        _favoriteItemIds.add(itemId);
      }
    });

    try {
      await _itemService.addFavorite(_userId!, itemId);
    } catch (e) {
      // revert on failure
      setState(() {
        if (_favoriteItemIds.contains(itemId)) {
          _favoriteItemIds.remove(itemId);
        } else {
          _favoriteItemIds.add(itemId);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to update favorite. Please try again.')),
    );
    print('Error toggling favorite: $e');
    }
  }

 @override
  void initState() {
    super.initState();
    _initUserAndData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      await userVM.loadUser(); // Make sure user is loaded

      final chatVM = Provider.of<ChatMessageViewModel>(context, listen: false);
        chatVM.initialize(currentUserId: userVM.userId);// Pass current user ID here

        if (chatVM.currentUserId != null) {
          await chatVM.fetchUnreadMessagesForSeller();

          // **Fetch unread count from API for the badge**
          await chatVM.fetchUnreadMessageCount();
        } else {
          print('Error: currentUserId is null in SellerHomeScreen initState');
        }
    });
    
    // Load cart data once
    Future.microtask(() async {
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      final userId = await AuthService.getCurrentUserId();
      if (userId != null) {
        cartViewModel.loadCartItems(userId);
      }
    });
  }

  Future<void> _initUserAndData() async {
    _userId = await AuthService.getCurrentUserId();
    if (_userId == null) {
      // Handle user not logged in (optional)
      print('No logged-in user found.');
      return;
    }
    await _loadCachedFavorites();
    await _loadFavorites();
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

  // Cache favorites locally (dummy implementation, replace with actual caching if needed)
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Consumer<ChatMessageViewModel>(
    builder: (context, chatVM, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: HamburgerMenu(
          userType: userType,
          onLogout: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        backgroundColor: AppColors.base,
        appBar: _selectedIndex == 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Consumer2<CartViewModel, ChatMessageViewModel>(
                  builder: (context, cartViewModel, chatViewModel, _) {
                    return TopNavBar(
                      searchController: _searchController,
                      onSearchSubmitted: _onSearchSubmitted,
                      cartCount: cartViewModel.itemCount,
                      chatCount: chatVM.unreadCount, 
                      onCartPressed: () {
                        Navigator.pushNamed(context, '/cartPage');
                      },
                    );
                  },
                ),
              )
            : null,
        body: _getPage(_selectedIndex),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          userType: userType,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      );
    },
  );
}


  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeScreenContent(
          favoriteItemIds: _favoriteItemIds,
          onFavoriteToggle: _toggleFavorite,
          userId: _userId,
          itemService: _itemService,);
      case 1:
        return const ExplorePage();
      case 2:
        return const Center(child: Text("Notifications Page - Coming Soon"));
      case 3:
        return MyLikesPage(
        userId: _userId!,
        favoriteItemIds: _favoriteItemIds,
        onFavoriteToggle: _toggleFavorite,
      );
      case 4:
        return ProfilePage(userType: userType);
      default:
        return HomeScreenContent(favoriteItemIds: const <int>{}, onFavoriteToggle: (int _) {}, userId: null, itemService: ItemService(),);
    }
  }
}

class HomeScreenContent extends StatefulWidget {
  final Set<int> favoriteItemIds;
  final Function(int) onFavoriteToggle;
  final int? userId;
  final ItemService itemService;
  
  const HomeScreenContent({
    super.key,
    required this.favoriteItemIds,
    required this.onFavoriteToggle,
    required this.userId,
    required this.itemService,
  });

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final String baseUrl = 'http://.1:8000';
  final String imageFolder = '/storage/events/';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventViewModel>().getLatestEvents();
      context.read<ItemViewModel>().getLatestItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), // extra bottom padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventSection(context),
              const SizedBox(height: 20),
              _buildSectionHeader("Popular Categories"),
              _buildCategoryList(context),
              const SizedBox(height: 20),
              _buildSectionHeader("Daily Explore"),
              _buildProductGrid(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildEventSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Don't Miss This", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AllEventsPage()));
              },
              child: const Text('See More'),
            ),
          ],
        ),
        Consumer<EventViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.latestEvents.isEmpty) {
              return const Center(child: Text("No events available"));
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vm.latestEvents.length,
                itemBuilder: (context, index) {
                  final event = vm.latestEvents[index];
                  final fullImageUrl = event.fullPosterUrl;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsPage(event: event, imagePath: ''),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(fullImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      { "icon": Icons.woman, "name": "Women Clothes" },
      { "icon": Icons.man, "name": "Men Clothes" },
      { "icon": Icons.favorite, "name": "Beauty & Health" },
      { "icon": Icons.pets, "name": "Pet Supplies" },
      { "icon": Icons.sports_soccer, "name": "Sports & Outdoors" },
      { "icon": Icons.electrical_services, "name": "Electronics" },
      { "icon": Icons.chair, "name": "Furniture" },
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryItemsScreen(
                    categoryName: categories[index]["name"],
                  ),
                ),
              );
            },
            child: _buildCategoryIconCard(
              categories[index]["icon"],
              categories[index]["name"],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryIconCard(IconData icon, String name) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.color2),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Consumer<ItemViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.latestItems.isEmpty) {
          return const Center(child: Text("No items available"));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: vm.latestItems.length,
          itemBuilder: (context, index) {
            final item = vm.latestItems[index];
            return ItemCardExplore(
              imageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : '',
              name: item.name,
              price: item.price,
              condition: item.condition, 
              seller: item.seller ?? '', 
              itemId: item.id,
              isFavorite: widget.favoriteItemIds.contains(item.id),
              onFavoriteToggle: () => widget.onFavoriteToggle(item.id),
            );
          },
        );
      },
    );
  }
}
