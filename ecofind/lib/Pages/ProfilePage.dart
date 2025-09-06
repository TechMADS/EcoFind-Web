// main.dart
import 'dart:io';
import 'dart:math';
import 'package:ecofind/Components/Colors.dart';
import 'package:ecofind/Pages/NewProduct.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const MyApp());
}

final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seller Dashboard - EcoFinds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: _dark ? Brightness.dark : Brightness.light,
      ),
      home: DashboardShell(onToggleTheme: () => setState(() => _dark = !_dark)),
    );
  }
}

/// DashboardShell: wraps Dashboard + bottom navigation
class DashboardShell extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const DashboardShell({required this.onToggleTheme, super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _index = 0;
  final pages = [
    const DashboardPage(),
    const MyListingsPage(),
    const PurchasesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Listings',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Purchases',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Quick add product action
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductQuickPage()),
          );
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add Listing'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// DashboardPage: main profile/dashboard
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  // user
  String name = 'Adhi Karthik';
  String email = 'adhi@example.com';
  String phone = '+91 98xxxxxxx';
  String about = 'Seller • Electronics & Pre-loved finds';
  File? _avatarFile;
  final ImagePicker _picker = ImagePicker();

  // sample stats
  int ordersToday = 3;
  int activeListings = 12;
  int wishlistCount = 8;

  // recent activity & messages
  List<Map<String, String>> recent = [
    {'title': 'Sold: Nike Air', 'time': '2h ago'},
    {'title': 'New message from Aman', 'time': '5h ago'},
    {'title': 'Listing approved: Smartwatch', 'time': '1d ago'},
  ];
  List<Map<String, dynamic>> listings = List.generate(
    6,
    (i) => {
      'id': i,
      'title':
          [
            'Nike Air',
            'AeroWatch',
            'Earbuds X',
            'Retro Lamp',
            'Wooden Chair',
            'Mountain Bike',
          ][i % 6],
      'price': (999 + Random().nextInt(6000)),
      'image': ['2.png', '3.png', '4.png', '5.png', '6.png', '7.png'],
    },
  );

  // animation controllers
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) setState(() => _avatarFile = File(file.path));
  }

  void _editProfile() {
    final nameCtrl = TextEditingController(text: name);
    final emailCtrl = TextEditingController(text: email);
    final phoneCtrl = TextEditingController(text: phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.6,
            child: Scaffold(
              appBar: AppBar(title: const Text('Edit profile')),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              name = nameCtrl.text;
                              email = emailCtrl.text;
                              phone = phoneCtrl.text;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext ctx) {
    final width = MediaQuery.of(ctx).size.width;
    final isWide = width > 800;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child:
            isWide
                ? Row(
                  children: [
                    _avatarBlock(),
                    const SizedBox(width: 18),
                    Expanded(child: _profileInfo()),
                    const SizedBox(width: 18),
                    _quickStats(),
                  ],
                )
                : Column(
                  children: [
                    Row(
                      children: [
                        _avatarBlock(),
                        const SizedBox(width: 12),
                        Expanded(child: _profileInfo()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _quickStats(),
                  ],
                ),
      ),
    );
  }

  Widget _avatarBlock() {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Hero(
        tag: 'profile-hero',
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  _avatarFile != null
                      ? FileImage(_avatarFile!)
                      : NetworkImage('https://i.pravatar.cc/150?u=adhi')
                          as ImageProvider,
            ),
            Positioned(
              right: 0,
              child: ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.06).animate(_pulseController),
                child: Material(
                  color: Colors.teal,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _pickAvatar,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(email, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        Text(phone, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 10),
        Text(about, style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddProductPage()),
                  ),
              icon: const Icon(Icons.list, color: Colors.white),
              label: const Text('Add Products'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // Change background color
                foregroundColor: Colors.white, // Text/Icon color
              ),
            ),
            OutlinedButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PurchasesPage()),
                  ),
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
              ),
              label: const Text('My Purchases'),
              style: OutlinedButton.styleFrom(
                backgroundColor: primaryColor, // Background for outlined button
                foregroundColor: Colors.white, // Icon & text color
                side: const BorderSide(color: Colors.black), // Border color
              ),
            ),
            SizedBox(height: 50),
            OutlinedButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistPage()),
                  ),
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              label: const Text('Wishlist'),
              style: OutlinedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickStats() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statCard(
          'Orders Today',
          ordersToday.toString(),
          Icons.trending_up,
          Colors.white,
        ),
        const SizedBox(width: 10),
        _statCard(
          'Listings',
          activeListings.toString(),
          Icons.shopify,
          Colors.white,
        ),
        const SizedBox(width: 10),
        _statCard(
          'Wishlist',
          wishlistCount.toString(),
          Icons.favorite,
          Colors.white,
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        width: 120,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityAndListings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 450),
            childAnimationBuilder:
                (widget) =>
                    ScaleAnimation(child: FadeInAnimation(child: widget)),
            children: [
              const SizedBox(height: 8),
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _activityList(),
              const SizedBox(height: 18),
              const Text(
                'Your Listings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _listingsGrid(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityList() {
    if (recent.isEmpty) {
      return Center(
        child: Lottie.asset('assets/lottie/empty.json', width: 140),
      );
    }
    return Column(
      children:
          recent.map((r) {
            return ListTile(
              tileColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: CircleAvatar(
                child: Icon(Icons.history, color: Colors.white),
                backgroundColor: Colors.teal,
              ),
              title: Text(r['title'] ?? ''),
              subtitle: Text(r['time'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {},
              ),
            );
          }).toList(),
    );
  }

  Widget _listingsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross =
            constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 600
                ? 3
                : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listings.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisExtent: 240,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, idx) {
            final item = listings[idx];
            return AnimationConfiguration.staggeredGrid(
              position: idx,
              duration: const Duration(milliseconds: 450),
              columnCount: cross,
              child: ScaleAnimation(
                child: FadeInAnimation(child: _listingCard(item)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _listingCard(Map<String, dynamic> item) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ListingDetailPage(item: item)),
          );
        },
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                item['image'],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        currencyFmt.format(item['price']),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _removeListing(item['id']),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeListing(dynamic id) {
    setState(() => listings.removeWhere((l) => l['id'] == id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Listing removed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Profile & Dashboard'),
        actions: [
          IconButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessagesPage()),
                ),
            icon: const Icon(Icons.message_outlined),
          ),
          IconButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                ),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 700));
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [_buildHeader(context), _buildActivityAndListings()],
          ),
        ),
      ),
    );
  }
}

/// Simple Listing Detail
class ListingDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ListingDetailPage({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item['title'])),
      body: Column(
        children: [
          Hero(
            tag: 'listing-${item['id']}',
            child: Image.network(
              item['image'],
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFmt.format(item['price']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Detailed description goes here. Add specs, condition, shipping info and seller details.',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.message),
                label: const Text('Message'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Promote Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// MyListingsPage (separate)
class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For demo just reuse a static list
    return Scaffold(
      appBar: AppBar(title: const Text('My Listings'), centerTitle: true),
      body: Center(
        child: Text(
          'This page lists all your products. Implement backend to load real items.',
        ),
      ),
    );
  }
}

/// PurchasesPage (separate)
class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo: empty state animation
    return Scaffold(
      appBar: AppBar(title: const Text('My Purchases')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/lottie/empty.json', width: 180),
            const SizedBox(height: 8),
            const Text('No purchases yet'),
          ],
        ),
      ),
    );
  }
}

/// WishlistPage (separate)
class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: const Center(child: Text('Wishlist items shown here')),
    );
  }
}

/// MessagesPage (separate)
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = List.generate(
      4,
      (i) => {
        'from': 'User ${i + 1}',
        'msg': 'Hi, is this available?',
        'time': '${i + 1}h',
      },
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder:
            (ctx, i) => ListTile(
              leading: CircleAvatar(child: Text(messages[i]['from']![0])),
              title: Text(messages[i]['from']!),
              subtitle: Text(messages[i]['msg']!),
              trailing: Text(messages[i]['time']!),
            ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: messages.length,
      ),
    );
  }
}

/// NotificationsPage
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nots = List.generate(
      3,
      (i) =>
          'Notification ${i + 1} - Your listing was viewed ${Random().nextInt(20) + 1} times',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: nots.length,
        itemBuilder: (ctx, i) => ListTile(title: Text(nots[i])),
      ),
    );
  }
}

/// SettingsPage (static)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            subtitle: const Text('Manage your account'),
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payments'),
            subtitle: const Text('Payment methods & payouts'),
          ),
          ListTile(
            leading: const Icon(Icons.support),
            title: const Text('Support'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

/// Quick Add Product small flow
class AddProductQuickPage extends StatefulWidget {
  const AddProductQuickPage({super.key});

  @override
  State<AddProductQuickPage> createState() => _AddProductQuickPageState();
}

class _AddProductQuickPageState extends State<AddProductQuickPage> {
  final _title = TextEditingController();
  final _price = TextEditingController();
  File? _img;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pick() async {
    final f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (f != null) setState(() => _img = File(f.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick add listing')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pick,
              child:
                  _img == null
                      ? Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade200,
                        ),
                        child: const Center(
                          child: Icon(Icons.add_a_photo, size: 36),
                        ),
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _img!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quick listing added (demo)')),
                );
                Navigator.pop(context);
              },
              child: const Text('Add Listing'),
            ),
          ],
        ),
      ),
    );
  }
}
