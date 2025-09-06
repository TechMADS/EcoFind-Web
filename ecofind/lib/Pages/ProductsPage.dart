import 'package:flutter/material.dart';
import 'package:ecofind/Pages/SingleProduct_View.dart';

import '../Components/Colors.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final listings = [
      {
        "name": "Cotton Shirt",
        "price": 12,
        "category": "Apparel",
        "status": "Available",
        "seller": "Anita S.",
        "image": "assets/shirt.jpg",
      },
      {
        "name": "Ladies Watch",
        "price": 35,
        "category": "Accessories",
        "status": "Available",
        "seller": "Rajesh K.",
        "image": "assets/watch.jpg",
      },
      {
        "name": "Wooden Chair",
        "price": 50,
        "category": "Furniture",
        "status": "Sold",
        "seller": "Priya V.",
        "image": "assets/chair1.jpg",
      },
      {
        "name": " Bag",
        "price": 20,
        "category": "Bags",
        "status": "Available",
        "seller": "John D.",
        "image": "assets/chair.jpg",
      },
      {
        "name": "Recycled Lamp",
        "price": 18,
        "category": "Home Decor",
        "status": "Available",
        "seller": "Meera P.",
        "image": "assets/chair1.jpg",
      },
    ];

    void _showSortOptions(
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
            child: ListTile(
              leading: Icon(Icons.star),
              title: Text("Top Rated"),
            ),
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

    void _showFilterOptions(
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

    void _showGroupOptions(
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
            child: ListTile(
              leading: Icon(Icons.store),
              title: Text("By Seller"),
            ),
          ),
        ],
      );
    }

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("EcoFinds"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "1",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Listings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text(
                    "Add New",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
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
            const SizedBox(height: 12),

            // Product Listings
            Expanded(
              child: ListView.builder(
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final product = listings[index];
                  return _ProductCard(
                    product: product,
                    name: product["name"] as String,
                    price: product["price"] as String,
                    catagory: product["catagory"] as String,
                    image: product["image"] as String,
                    Seller: product["seller"] as String,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  _ProductCard({
    required this.product,
    required this.name,
    required this.price,
    required this.catagory,
    required this.image,
    required this.Seller, this.Stringimage,
  });

  final Stringimage;
  final String price;
  final String catagory;
  final String Seller;
  final String image;
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailsPage(
                  name: "$name",
                  price: price,
                  catagory: catagory,
                  image: "$image",
                  Seller: Seller,
                ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full image
              Image.asset(
                product["image"]!,

                fit: BoxFit.cover,
                // loadingBuilder: (context, child, progress) {
                //   if (progress == null) return child;
                //   return const Center(child: CircularProgressIndicator());
                // },
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // Product details over image
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product["name"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Price: \$${product["price"]}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      "Category: ${product["category"]}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "Status: ${product["status"]}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "Seller: ${product["seller"]}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ActionChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
