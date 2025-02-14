import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_ecommerce/API_Service/users/profile_service.dart';
import 'package:shop_ecommerce/UI_Screen/authentication/sign_in.dart';
import 'package:shop_ecommerce/UI_Screen/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> _handleEditProfile(BuildContext context) async {
    bool isLoggedIn = await checkLoginStatus();
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final data = await fetchUserProfile();
    if (mounted) {
      setState(() {
        userData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Information Section
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: userData?['image'] != null
                      ? MemoryImage(base64Decode(userData!['image']))
                      : const NetworkImage(
                          'https://via.placeholder.com/150'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData?['name'] ?? 'Loading...',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userData?['email'] ?? 'Loading...',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _handleEditProfile(context);
                  },
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            // Menu Items
            _buildMenuItem(context, Icons.home, 'Home'),
            _buildExpandableMenuItem(
                context, Icons.category, 'Category', _categorySubMenu()),
            _buildExpandableMenuItem(
                context, Icons.settings, 'Settings', _settingsSubMenu()),
            _buildMenuItem(context, Icons.help, 'Help'),
            _buildMenuItem(context, Icons.info, 'About Us'),
            _buildMenuItem(context, Icons.contact_mail, 'Contact Us'),
            _buildMenuItem(context, Icons.message, 'My Message'),
            const Divider(height: 20, thickness: 1),
            _buildMenuItem(context, Icons.logout, 'Logout', isLogout: true),
          ],
        ),
      ),
    );
  }

  // Helper method to build expandable menu items
  Widget _buildExpandableMenuItem(BuildContext context, IconData icon, String title, Widget subMenu) {
    return ExpansionTile(
      leading: Icon(icon,size: 20,),
      title: Text(title,style: const TextStyle(fontSize: 18),),
      childrenPadding: const EdgeInsets.only(left: 32.0),
      children: [subMenu],
    );
  }

  // Sub-menu for Category
  Widget _categorySubMenu() {
    return Column(
      children: [
        _buildMenuItem(context, Icons.folder, 'Sub-Category 1'),
        _buildMenuItem(context, Icons.folder_open, 'Sub-Category 2'),
      ],
    );
  }

  // Sub-menu for Settings
  Widget _settingsSubMenu() {
    return Column(
      children: [
        _buildMenuItem(context, Icons.password, 'Change Password'),
        _buildMenuItem(context, Icons.palette, 'Theme Settings'),
        _buildMenuItem(context, Icons.notifications, 'Notification Settings'),
      ],
    );
  }

  // Helper method to build menu items
  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (isLogout) {
          _logout();
        } else {
          print('$title clicked');
        }
      },
    );
  }
}
