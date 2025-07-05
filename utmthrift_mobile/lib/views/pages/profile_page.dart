// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/views/buyer/seller_application_page.dart';
import 'package:utmthrift_mobile/views/order/order_history_page.dart';
import 'package:utmthrift_mobile/views/profile/profile_edit.dart';
import 'package:utmthrift_mobile/views/seller/seller_sales_tracking_page.dart';
import 'package:utmthrift_mobile/views/seller/seller_upload_qrcode_page.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import 'package:utmthrift_mobile/services/auth_service.dart';
import 'package:utmthrift_mobile/viewmodels/profile_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  final String userType;
  final VoidCallback? onTap;

  const ProfilePage({super.key, required this.userType, this.onTap});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  @override
  void initState() {
    super.initState();
    Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.base,
      appBar: AppBar(
        backgroundColor: AppColors.color2, // Using maroon color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.base),
          onPressed: () {},
        ),
        title: const Text("My Profile", 
               style: TextStyle(
                 fontSize: 18, 
                 fontWeight: FontWeight.bold,
                 color: AppColors.base,
               )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(profileVM),
              const SizedBox(height: 24),
              _buildSectionTitle("My Account"),
              _buildMenuOption(Icons.person_outline, "Profile", () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
                Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile refreshed successfully!"),
                    backgroundColor: AppColors.color13, // Green for success
                    duration: Duration(seconds: 2),
                  ),
                );
              }),
              _buildMenuOption(Icons.favorite_border, "Liked", () {}),
              _buildMenuOption(Icons.shopping_bag_outlined, "My Purchases", () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
                );
              }),
              const SizedBox(height: 24),
              _buildSectionTitle("More Information"),
              widget.userType == "Seller"
                ? _buildMenuOption(Icons.qr_code_scanner, "Upload QR Code", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UploadQrCodePage()),
                    );
                  })
                : _buildMenuOption(Icons.storefront_outlined, "Become a Seller", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellerApplicationPage()),
                    );
                  }),
              if (widget.userType == "Seller") ...[
                _buildMenuOption(Icons.analytics_outlined, "Track Sales", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalesTrackingPage(
                        sellerId: profileVM.user?.id ?? 0),
                    ),
                  );
                }),
              ],
              _buildMenuOption(Icons.settings_outlined, "Settings", () {}),
              const SizedBox(height: 16),
              _buildLogoutOption(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.color10.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel profileVM) {
    if (profileVM.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.color2, // Maroon loading indicator
        ),
      );
    }

    final user = profileVM.user;
    final hasProfilePic = user?.profilePicture != null &&
        user!.profilePicture!.isNotEmpty &&
        user.profilePicture!.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.color12, // Light yellow background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          hasProfilePic
              ? CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.color3, // Light pink fallback
                  backgroundImage: NetworkImage(user.profilePicture!),
                )
              : const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.color3,
                  child: Icon(Icons.person, size: 40, color: AppColors.color2),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, ${user?.name ?? "User"}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.color10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "No email",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.color10.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Member since ${user?.createdAtFormatted ?? "Unknown"}",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.color10.withOpacity(0.4),
                  ),
                ),
              ],  
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        color: AppColors.color11, // Light pink background
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.base, // Cream background for icon
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.color2), // Maroon icon
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.color10,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.color10.withOpacity(0.6),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildLogoutOption(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      color: AppColors.color11.withOpacity(0.8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.logout,
            color: Colors.red[700],
          ),
        ),
        title: Text(
          "Sign Out",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red[700],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.red[700]!.withOpacity(0.6),
        ),
        onTap: () => AuthService.logout(context),
      ),
    );
  }
}