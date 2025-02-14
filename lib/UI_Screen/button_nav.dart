import 'package:flutter/material.dart';
import 'package:shop_ecommerce/UI_Screen/products/add_product.dart';
import 'package:shop_ecommerce/UI_Screen/cart_page.dart';
import 'package:shop_ecommerce/UI_Screen/favorate_page.dart';
import 'package:shop_ecommerce/UI_Screen/home_page.dart';
import 'package:shop_ecommerce/UI_Screen/profile_page.dart';

class NavButtonPage extends StatefulWidget {
  const NavButtonPage({super.key});

  @override
  State<NavButtonPage> createState() => _NavButtonPageState();
}

class _NavButtonPageState extends State<NavButtonPage> {
  int selectedIndex = 0;
  // List of pages for navigation
  final List<Widget> pages = [
    const HomeScreen(),
    const CartPage(),
    const AddProductScreen(),
    const FavouriteScreen(),
    const ProfileScreen(),   
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight,
                maxWidth: constraints.maxWidth,
              ),
              child: IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          backgroundColor: Colors.white, 
          selectedItemColor: Colors.blue, 
          unselectedItemColor: Colors.grey, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Add product',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favourite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
