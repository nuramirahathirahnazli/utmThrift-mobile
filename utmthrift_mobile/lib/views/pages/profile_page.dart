// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utmthrift_mobile/views/profile/profile_edit.dart';
import 'package:utmthrift_mobile/views/shared/colors.dart';
import 'package:utmthrift_mobile/services/auth_service.dart';
import 'package:utmthrift_mobile/viewmodels/profile_viewmodel.dart';

class ProfilePage extends StatefulWidget {
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

              _buildMenuOption(Icons.lock, "Password", () {}),
              _buildMenuOption(Icons.favorite, "Liked", () {}),
              _buildMenuOption(Icons.shopping_cart, "My Purchases", () {}),
              const SizedBox(height: 20),
              const Text("More Information", 
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              _buildMenuOption(Icons.store, "Become a Seller", () {}),
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
                backgroundImage: NetworkImage(user!.profilePicture!),  // Use the profile URL from backend
              )
            : const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/profile_pic.png'),
              ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Hi, ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(user?.name ?? "No data", 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.color10)),
              ],
            ),
            Text(user?.email ?? "No email", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text("Since ${user?.createdAtFormatted ?? "Unknown"}", 
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
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
