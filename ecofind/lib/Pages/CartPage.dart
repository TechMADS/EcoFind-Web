import 'package:ecofind/Components/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:ecofind/Components/Appbar.dart';


final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2F6FED),
        brightness: Brightness.light,
      ),
      home: const CartPage(),
    );
  }
}

class CartItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price; // MRP
  final double discount; // e.g. 0.15 for 15%
  final double rating; // 0..5
  int qty;
  bool wishlisted;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.rating,
    this.qty = 1,
    this.wishlisted = false,
  });

  double get effectivePrice => price * (1 - discount);

  double get lineTotal => effectivePrice * qty;

  double get lineSavings => (price - effectivePrice) * qty;
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  final List<CartItem> _cart = [
    CartItem(
      id: 'nike-sneakers',
      name: 'Nike Air Sneakers',
      description: 'Breathable mesh • Cushioned sole',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1000',
      price: 4999,
      discount: 0.20,
      rating: 4.4,
      qty: 1,
    ),
    CartItem(
      id: 'smart-watch',
      name: 'AeroFit Smart Watch',
      description: 'AMOLED • SpO₂ • 10-day battery',
      imageUrl:
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=1000',
      price: 3999,
      discount: 0.10,
      rating: 4.1,
      qty: 1,
    ),
    CartItem(
      id: 'earbuds',
      name: 'Nimbus Wireless Earbuds',
      description: 'ENC mic • Low latency',
      imageUrl:
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=1000',
      price: 2499,
      discount: 0.28,
      rating: 4.2,
      qty: 2,
    ),
  ];

  final List<CartItem> _savedForLater = [];

  // Coupon: SAVE10 => 10% off on cart subtotal (after product discounts).
  String? _appliedCoupon;
  final TextEditingController _couponCtrl = TextEditingController();

  // For animated Checkout button bounce/scale
  double _checkoutScale = 1.0;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  // ---- Pricing helpers ----
  double get _subtotal => _cart.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get _productSavings =>
      _cart.fold(0.0, (sum, item) => sum + item.lineSavings);

  double get _couponSavings {
    if (_appliedCoupon == 'SAVE10') {
      return _subtotal * 0.10;
    }
    return 0.0;
  }

  double get _grandTotal =>
      (_subtotal - _couponSavings).clamp(0, double.infinity);

  String _etaText() {
    final now = DateTime.now();
    final delivery = now.add(const Duration(days: 2));
    final weekday = DateFormat('EEEE').format(delivery);
    final date = DateFormat('d MMM').format(delivery);
    return 'Delivery by $weekday, $date';
    // e.g., Delivery by Friday, 12 Sep
  }

  void _applyCoupon() {
    final code = _couponCtrl.text.trim().toUpperCase();
    setState(() {
      if (code == 'SAVE10') {
        _appliedCoupon = 'SAVE10';
      } else {
        _appliedCoupon = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid coupon. Try SAVE10')),
        );
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _toggleWishlist(CartItem item) {
    setState(() {
      item.wishlisted = !item.wishlisted;
    });
  }

  void _saveForLater(CartItem item) {
    setState(() {
      _cart.removeWhere((e) => e.id == item.id);
      _savedForLater.add(item);
    });
  }

  void _moveToCart(CartItem item) {
    setState(() {
      _savedForLater.removeWhere((e) => e.id == item.id);
      _cart.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = _cart.isNotEmpty;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: appbar(appbar_title: "Cart"),
      ),

      body: hasItems ? _buildCartBody() : _buildEmptyState(),
      bottomNavigationBar: hasItems ? _buildStickyCheckout() : null,
    );
  }

  // ---------------- UI sections ----------------

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            // Nice empty cart animation
            'https://assets7.lottiefiles.com/packages/lf20_jtbfg2nb.json',
            width: 240,
            repeat: true,
          ),
          const SizedBox(height: 12),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text('Add items to get started'),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Start shopping')),
        ],
      ),
    );
  }

  Widget _buildCartBody() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildCouponSection()),
        SliverToBoxAdapter(child: _priceSummaryCard()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Items (${_cart.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverList.builder(
            itemCount: _cart.length,
            itemBuilder: (context, index) {
              final item = _cart[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 450),
                child: SlideAnimation(
                  verticalOffset: 40,
                  child: FadeInAnimation(child: _cartTile(item, index)),
                ),
              );
            },
          ),
        ),
        if (_savedForLater.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Saved for later',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        if (_savedForLater.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList.builder(
              itemCount: _savedForLater.length,
              itemBuilder:
                  (context, index) => _savedTile(_savedForLater[index]),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 100)),
        // space for sticky btn
      ],
    );
  }

  Widget _cartTile(CartItem item, int index) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeFromCart(index),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [Colors.white, Colors.white]),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: item.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + wishlist
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _toggleWishlist(item),
                            icon: Icon(
                              item.wishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            tooltip: 'Wishlist',
                          ),
                        ],
                      ),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _ratingStars(item.rating),
                      const SizedBox(height: 8),
                      // Price row (show MRP with strike, discount, effective)
                      Row(
                        children: [
                          Text(
                            _currency.format(item.effectivePrice),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.discount > 0)
                            Text(
                              _currency.format(item.price),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          if (item.discount > 0) const SizedBox(width: 6),
                          if (item.discount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${(item.discount * 100).round()}% OFF',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _etaText(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Qty controls + Save for later
                      Row(
                        children: [
                          _qtyControl(
                            value: item.qty,
                            onMinus: () {
                              setState(() {
                                if (item.qty > 1) item.qty--;
                              });
                            },
                            onPlus: () {
                              setState(() => item.qty++);
                            },
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _saveForLater(item),
                            icon: const Icon(Icons.bookmark_outline),
                            label: const Text('Save for later'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _savedTile(CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            item.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_currency.format(item.effectivePrice)),
        trailing: FilledButton.tonal(
          onPressed: () => _moveToCart(item),
          child: const Text('Move to cart'),
        ),
      ),
    );
  }

  Widget _qtyControl({
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      children: [
        InkResponse(
          radius: 22,
          onTap: onMinus,
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(Icons.remove_circle_outline),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder:
              (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Text(
            '$value',
            key: ValueKey<int>(value),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        InkResponse(
          radius: 22,
          onTap: onPlus,
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(Icons.add_circle_outline),
          ),
        ),
      ],
    );
  }

  Widget _ratingStars(double rating) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < full
                ? Icons.star
                : (i == full && half ? Icons.star_half : Icons.star_border),
            size: 18,
            color: Colors.amber,
          ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ],
    );
  }

  Widget _buildCouponSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: const Icon(Icons.local_offer_outlined),
        title: const Text('Have a promo code?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Enter coupon',
                    hintText: 'Try SAVE10',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
                onPressed: _applyCoupon,
                child: const Text('Apply'),
              ),
            ],
          ),
          if (_appliedCoupon != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Coupon $_appliedCoupon applied',
                  style: const TextStyle(color: Colors.green),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _appliedCoupon = null),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceSummaryCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade300],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                _priceRow('Subtotal', _currency.format(_subtotal)),
                _priceRow(
                  'Savings on MRP',
                  '- ${_currency.format(_productSavings)}',
                  valueStyle: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_couponSavings > 0)
                  _priceRow(
                    'Coupon discount',
                    '- ${_currency.format(_couponSavings)}',
                    valueStyle: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const Divider(height: 20),
                _priceRow(
                  'Total',
                  _currency.format(_grandTotal),
                  isLarge: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool isLarge = false,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isLarge ? FontWeight.w700 : FontWeight.w500,
              fontSize: isLarge ? 16 : 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style:
                valueStyle ??
                TextStyle(
                  fontWeight: isLarge ? FontWeight.w800 : FontWeight.w600,
                  fontSize: isLarge ? 18 : 14,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyCheckout() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: AnimatedScale(
          scale: _checkoutScale,
          duration: const Duration(milliseconds: 140),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              // bounce effect
              setState(() => _checkoutScale = 0.96);
              await Future.delayed(const Duration(milliseconds: 110));
              setState(() => _checkoutScale = 1.0);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Checking out for ${_currency.format(_grandTotal)}',
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline),
                const SizedBox(width: 10),
                Text(
                  'Checkout • ${_currency.format(_grandTotal)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
