import 'dart:ui';
import 'package:ecofind/Pages/ProfilePage.dart';
import 'package:ecofind/Components/BottomNavigation.dart';
import 'package:ecofind/Pages/suppose.dart';
import 'package:flutter/material.dart';
import 'package:ecofind/Components/Colors.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class EcoFindsLandingPage extends StatelessWidget {
  EcoFindsLandingPage({super.key});

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      // bottomNavigationBar: NavBar(),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor], // Purple-Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: const Text(
          "EcoFinds",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed("/cart");
                },
              ),
              Positioned(
                right: 8,
                top: 1,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "1",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {Navigator.of(context).pushNamed("/profile");
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),

        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2.0)
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      "Sort",
                      Icons.swap_vert,
                      (ctx, pos, size) => _showSortOptions(ctx, pos, size),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      "Filter",
                      Icons.filter_list,
                      (ctx, pos, size) => _showFilterOptions(ctx, pos, size),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      "Group",
                      Icons.grid_view,
                      (ctx, pos, size) => _showGroupOptions(ctx, pos, size),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              // Banner_Image(),

              // Banner Image
              Banner_Image(),

              // Container(
              //   height: 380,
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     image: DecorationImage(image: AssetImage("assets/1.png")),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: const Center(
              //     child: Text(
              //       "Banner Image 🌱",
              //       style: TextStyle(
              //         fontSize: 22,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 30),

              // ✅ Move "All Categories" Button right below banner
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/products");
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, primaryColor], // Orange-Red
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "All Categories",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Categories Grid
              // GridView.count(
              //   crossAxisCount: width > 600 ? 4 : 3,
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   crossAxisSpacing: 12,
              //   mainAxisSpacing: 12,
              //   children: [
              //     _buildCategoryCard("Clothing"),
              //     _buildCategoryCard("Electronics"),
              //     _buildCategoryCard("Home"),
              //     _buildCategoryCard("Books"),
              //     _buildCategoryCard("Sports"),
              //     _buildCategoryCard("Furniture"),
              //     _buildCategoryCard("Kids"),
              //     _buildCategoryCard("Accessories"),
              //     _buildCategoryCard("Vessels"),
              //   ],
              // ),
              EcoFindsLandingPage2(),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Action Button Builder
  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    Function(BuildContext, Offset, Size) onTap,
  ) {
    return Builder(
      builder: (buttonContext) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryColor, primaryColor], // Purple gradient
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final RenderBox button =
                  buttonContext.findRenderObject() as RenderBox;
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final Offset offset = button.localToGlobal(
                Offset.zero,
                ancestor: overlay,
              );
              final Size size = button.size;
              onTap(context, offset, size); // pass position + size
            },
            icon: Icon(icon, size: 18, color: Colors.white),
            label: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }

  // Category Card Builder
  Widget _buildCategoryCard(String title) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)], // Aqua-Blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sort Menu
  static void _showSortOptions(
    BuildContext context,
    Offset offset,
    Size size,
  ) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height, // directly below button
        offset.dx + size.width,
        0,
      ),
      items: const [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.arrow_upward),
            title: Text("Price: Low to High"),
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.arrow_downward),
            title: Text("Price: High to Low"),
          ),
        ),
        PopupMenuItem(
          child: ListTile(leading: Icon(Icons.star), title: Text("Top Rated")),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.new_releases),
            title: Text("Newest"),
          ),
        ),
      ],
    );
  }

  // Filter Menu
  static void _showFilterOptions(
    BuildContext context,
    Offset offset,
    Size size,
  ) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        0,
      ),
      items: const [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.checkroom),
            title: Text("Clothing"),
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.devices),
            title: Text("Electronics"),
          ),
        ),
        PopupMenuItem(
          child: ListTile(leading: Icon(Icons.home), title: Text("Home")),
        ),
        PopupMenuItem(
          child: ListTile(leading: Icon(Icons.book), title: Text("Books")),
        ),
      ],
    );
  }

  // Group Menu
  static void _showGroupOptions(
    BuildContext context,
    Offset offset,
    Size size,
  ) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        0,
      ),
      items: const [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.category),
            title: Text("By Category"),
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.location_on),
            title: Text("By Location"),
          ),
        ),
        PopupMenuItem(
          child: ListTile(leading: Icon(Icons.store), title: Text("By Seller")),
        ),
      ],
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Glass blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          // Menu list
          ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Center(
                  child: Text(
                    "Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildMenuItem(Icons.add_box, "Add Product","/addnew", context, ),
              _buildMenuItem(Icons.person, "Profile","/profile", context),
              _buildMenuItem(Icons.person, "Cart","/cart", context),


            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildMenuItem(
    IconData icon,
    String title,
    String route,
    BuildContext context,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      onTap: () {
        Navigator.of(context).pushNamed("$route");
      },
    );
  }
}

class Banner_Image extends StatefulWidget {
  const Banner_Image({super.key});

  @override
  State<Banner_Image> createState() => _Banner_ImageState();
}

class _Banner_ImageState extends State<Banner_Image> {
  int activeIndex = 0;
  final CardSwiperController swiperController = CardSwiperController();

  final List<Map<String, String>> courses = [
    {"title": "", "description": "", "image": "assets/rp.1.png"},
    {"title": "", "description": "", "image": "assets/rp.2.png"},
    {"title": "", "description": "", "image": "assets/rp.3.png"},
    // {"title": "", "description": "", "image": "assets/page.3.png"},

  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 340,
          width: double.infinity,
          child: CardSwiper(
            controller: swiperController,
            cardsCount: courses.length,
            onSwipe: (previousIndex, currentIndex, direction) {
              setState(() => activeIndex = currentIndex ?? 0);
              return true;
            },
            cardBuilder: (context, index, percentX, percentY) {
              final course = courses[index];
              return GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.asset(
                          course["image"]!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Title + Description
                      // Padding(
                      //   padding: const EdgeInsets.all(12),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         course["title"]!,
                      //         style: const TextStyle(
                      //           fontSize: 18,
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //       const SizedBox(height: 6),
                      //       Text(
                      //         course["description"]!,
                      //         style: const TextStyle(
                      //           fontSize: 14,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16),

        // Page indicator
        AnimatedSmoothIndicator(
          activeIndex: activeIndex,
          count: courses.length,
          effect: ExpandingDotsEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: primaryColor,
            dotColor: Colors.grey.shade400,
          ),
        ),

        // Explore button
        SizedBox(height: 15),
      ],
    );
  }
}
