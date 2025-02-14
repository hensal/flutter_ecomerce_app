import 'package:flutter/material.dart';
import 'package:shop_ecommerce/UI_Screen/widgets/carousel_slider.dart';
import 'package:shop_ecommerce/UI_Screen/widgets/category.dart';
import 'package:shop_ecommerce/UI_Screen/widgets/location.dart';
import 'package:shop_ecommerce/UI_Screen/products/all_products_fetch.dart';
import 'package:shop_ecommerce/UI_Screen/search/search.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Function to show the location popup when the up arrow is pressed
  void _showLocationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LocationPopup(); // Use the LocationPopup here
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section with Location and Notification Icon
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 10, 211, 77), // Background color
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_pin,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'New York, USA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Drop-up Icon
                                GestureDetector(
                                  onTap: () {
                                      _showLocationPopup(context);
                                  },
                                  child: const Icon(
                                    Icons.arrow_drop_up,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                   const SearchFormFieldUI(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Carousel Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#SpecialForYou',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              CarouselWidget(),
              const SizedBox(height: 20),
              // Categories Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CategoryItemWidget(
                        icon: Icons.checkroom,
                        label: 'Clothes',
                        categoryName: 'clothes',
                      ),
                      CategoryItemWidget(
                        icon: Icons.book,
                        label: 'Books',
                         categoryName: 'books',
                      ),
                      CategoryItemWidget(
                        icon: Icons.shopping_bag,
                        label: 'Shoes',
                         categoryName: 'shoes',
                      ),
                      CategoryItemWidget(
                        icon: Icons.watch,
                        label: 'Watches',
                        categoryName: 'watches',
                      ),
                      CategoryItemWidget(
                        icon: Icons.phone_android,
                        label: 'Mobiles',
                         categoryName: 'mobiles',
                      ),
                      CategoryItemWidget(
                        icon: Icons.laptop,
                        label: 'Laptops',
                         categoryName: 'laptops',
                      ),
                      CategoryItemWidget(
                        icon: Icons.camera_alt,
                        label: 'Cameras',
                        categoryName: 'cameras',
                      ),
                      CategoryItemWidget(
                        icon: Icons.directions_car,
                        label: 'Car',
                        categoryName: 'cars',
                      ),
                    ],
                  )),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const ProductGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
