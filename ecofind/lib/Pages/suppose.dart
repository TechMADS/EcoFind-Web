import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class EcoFindsLandingPage2 extends StatefulWidget {
  const EcoFindsLandingPage2({super.key});

  @override
  State<EcoFindsLandingPage2> createState() => _EcoFindsLandingPage2State();
}

class _EcoFindsLandingPage2State extends State<EcoFindsLandingPage2> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allProducts = [
    {
      "name": "Nike Shoes",
      "price": 2999,
      "image": "assets/shoes.jpg",
      "rating": 4.5,
    },
    {
      "name": "iPhone 14",
      "price": 69999,
      "image": "assets/iphon.jpeg",
      "rating": 4.8,
    },
    {
      "name": "Laptop",
      "price": 45999,
      "image": "assets/laptop.jpeg",
      "rating": 4.6,
    },
    {
      "name": "Headphones",
      "price": 1999,
      "image": "assets/headphone.jpeg",
      "rating": 4.3,
    },
  ];
  List<Map<String, dynamic>> searchResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        searchResults = allProducts
            .where((p) => p["name"]
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return  SingleChildScrollView(
        child: Column(
          children: [
            // 🔍 Search bar


            if (_searchController.text.isNotEmpty)
              searchResults.isEmpty
                  ? const Text("No results found ❌",
                  style: TextStyle(color: Colors.red))
                  : _buildSearchResults(),

            if (_searchController.text.isEmpty) ...[
              _buildBanner(),
              _buildDealsSection(),
              _buildCategorySection(width),
              _buildRecommendedSection(),
            ],
          ],

      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.category), label: "Categories"),
      //     BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //   ],
      // ),
        ));
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage("assets/shoes.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDealsSection() {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("🔥 Deals of the Day",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
            ),

          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allProducts.length,
              itemBuilder: (context, index) {
                final product = allProducts[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 50,
                    child: FadeInAnimation(
                      child: _buildProductCard(product, 160),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCategorySection(double width) {
    List<Map<String, String>> categories = [
      {
        "title": "Electronics",
        "image": "assets/electronics.jpeg",
      },
      {
        "title": "Fashion",
        "image": "assets/fashion.jpg",
      },
      {
        "title": "Books",
        "image": "assets/book.jpeg",
      },
      {
        "title": "Home",
        "image": "assets/house.jpeg",
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.count(
        crossAxisCount: width > 600 ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: categories
            .map((c) => GestureDetector(
          onTap: () => Navigator.pushNamed(context, "/category/${c["title"]}"),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: AssetImage(c["image"]!), fit: BoxFit.cover),
            ),
            child: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.4),
              ),
              child: Text(c["title"]!,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text("⭐ Recommended for You",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        AnimationLimiter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final product = allProducts[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 500),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: _buildProductCard(product, 200),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, double height) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/product/${product["name"]}"),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: product["name"],
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(product["image"], fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(product["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("₹${product["price"]}",
                      style: const TextStyle(color: Colors.green)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return Icon(Icons.star,
                          color: i < product["rating"].round()
                              ? Colors.amber
                              : Colors.grey, size: 16);
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: searchResults.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final product = searchResults[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 2,
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: _buildProductCard(product, 200),
              ),
            ),
          );
        },
      ),
    );
  }
}
