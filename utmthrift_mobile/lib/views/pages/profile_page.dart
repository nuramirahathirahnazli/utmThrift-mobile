//profile page untuk buyer & seller
// ignore_for_file: library_private_types_in_public_api

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
        backgroundColor: AppColors.color3,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text("My Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(profileVM),
              const SizedBox(height: 20),
              _buildMenuOption(Icons.person, "Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              }),
              _buildMenuOption(Icons.favorite, "Liked", () {}),
              _buildMenuOption(Icons.shopping_cart, "My Purchases", () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
                );
              }),
              const SizedBox(height: 20),
              const Text("More Information", 
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              widget.userType == "Seller"
                ? _buildMenuOption(Icons.qr_code, "Upload QR Code", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UploadQrCodePage()),
                    );
                  })
                : _buildMenuOption(Icons.store, "Become a Seller", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SellerApplicationPage()),
                    );
                  }),
              if (widget.userType == "Seller") ...[
                _buildMenuOption(Icons.track_changes, "Track Sales", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalesTrackingPage(
                        sellerId: profileVM.user?.id ?? 0),
                    ),
                  );
                }),
              ],
              _buildMenuOption(Icons.settings, "Settings", () {}),
              _buildLogoutOption(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel profileVM) {
    if (profileVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = profileVM.user;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        user?.profilePicture != null
            ? CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user!.profilePicture!),
              )
            : const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/profile_pic.png'),
              ),
        const SizedBox(width: 15),
        Expanded( 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Hi, ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Flexible( // <-- Wrap the name to avoid long text overflow
                    child: Text(
                      user?.name ?? "No data",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.color10),
                    ),
                  ),
                ],
              ),
              Text(user?.email ?? "No email", style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text("Since ${user?.createdAtFormatted ?? "Unknown"}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: AppColors.color11, 
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.color12,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.color2),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutOption(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.logout, color: Colors.red),
        ),
        title: const Text("Sign Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => AuthService.logout(context),
      ),
    );
  }
}
