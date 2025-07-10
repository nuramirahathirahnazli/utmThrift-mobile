// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, unused_import, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/config/api_config.dart';

// Services
import 'package:utmthrift_mobile/services/chat_service.dart';
import 'package:utmthrift_mobile/services/item_service.dart';

// ViewModels
import 'package:utmthrift_mobile/viewmodels/chatmessage_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/event_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/item_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/signin_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/user_viewmodel.dart';

// Views
import 'package:utmthrift_mobile/views/events/all_events_page.dart';
import 'package:utmthrift_mobile/views/events/event_details_page.dart';
import 'package:utmthrift_mobile/views/items/item_card_explore.dart';
import 'package:utmthrift_mobile/views/items/item_category.dart';
import 'package:utmthrift_mobile/views/pages/explore_page.dart';

//Page based on bottom menu navigation
import 'package:utmthrift_mobile/views/pages/profile_page.dart';
import 'package:utmthrift_mobile/views/seller/seller_add_item_page.dart';
import 'package:utmthrift_mobile/views/seller/seller_my_items_page.dart';

//shared folder
import 'package:utmthrift_mobile/views/shared/bottom_nav.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import 'package:utmthrift_mobile/views/shared/top_nav.dart';

class SellerHomeScreen extends StatefulWidget {
  
  const SellerHomeScreen({
    super.key,
  });

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedIndex = 0;
  final String userType = 'Seller';
  final TextEditingController _searchController = TextEditingController();

  // Handle search submitted action
  void _onSearchSubmitted(String value) {
    print('Search submitted: $value');
  }

  @override
  void initState() {
    super.initState();
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
    
    Future.microtask(() {
        final eventVM = context.read<EventViewModel>();
        final itemVM = context.read<ItemViewModel>();

        eventVM.getLatestEvents();
        itemVM.getLatestItems();
      }
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
    final chatVM = context.watch<ChatMessageViewModel>();
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.base,
      appBar: _selectedIndex == 0 
      ? TopNavBar(
        searchController: _searchController,
        onSearchSubmitted: _onSearchSubmitted,
        cartCount: cartViewModel.totalQuantity,
        chatCount: chatVM.unreadCount, 
        onCartPressed: () {
          Navigator.pushNamed(context, '/cartPage'); // or your cart route
        },
        
      ) : null,
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
  }

// Function to return the appropriate page based on the selected index
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeScreenContent(
          favoriteItemIds: const <int>{}, // or pass from a ViewModel if available
          itemService: ItemService(), // or reuse a shared instance
          onFavoriteToggle: (int itemId) {
            // Add your favorite toggle logic here
            print("Favorite toggled for item: $itemId");
          },
        );

      case 1:
        return const ExplorePage();
      case 2:
        return const AddItemScreen(); 
      case 3:
        return const MyItemsPage();
      case 4:
        return ProfilePage(
          userType: userType,
          onGoToProfileTab: () {
            setState(() {
              _selectedIndex = 4;
            });
          },
        );
      default:
        return HomeScreenContent(
          favoriteItemIds: const <int>{}, // or pass from a ViewModel if available
          itemService: ItemService(), // or reuse a shared instance
          onFavoriteToggle: (int itemId) {
            // Add your favorite toggle logic here
            print("Favorite toggled for item: $itemId");
          },
        );
    }
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key, required Set<int> favoriteItemIds, int? userId, required ItemService itemService, required void Function(int itemId) onFavoriteToggle});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final String baseUrl = ApiConfig.baseUrl;  
  
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventSection(context),
            const SizedBox(height: 20),
            _buildSectionHeader("Popular Categories"),
            _buildCategoryList(context),
            const SizedBox(height: 20),
            _buildSectionHeader("Daily Explore"), //daily explore hanya akan keluar kan yang latest item dari database (up to 20)
            _buildProductGrid(),
          ],
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
    List<Map<String, dynamic>> categories = [
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
    final currentUserId = context.read<UserViewModel>().userId;

    return Consumer<ItemViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter out items where the item's sellerId matches the current logged-in seller
        final filteredItems = vm.latestItems
            .where((item) => item.sellerId != currentUserId)
            .toList();

        if (filteredItems.isEmpty) {
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
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return ItemCardExplore(
              imageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : '',
              name: item.name,
              price: item.price,
              condition: item.condition,
               seller: item.seller ?? '', 
              itemId: item.id,
              isFavorite: false,
              onFavoriteToggle: () {
                print("Toggled favorite for item ${item.id}");
              },
            );
          },
        );
      },
    );
  }

}

