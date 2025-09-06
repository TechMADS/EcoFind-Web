
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatefulWidget {
   ProductDetailsPage({super.key, required this.name,
   required this.price,
   required this.catagory,
   required this.image,
   required this.Seller
   });
  final String image;
  final String price;
  final String catagory;
  final String Seller;
  final String name;


  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool isFavorite = false;
  int selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final isTablet = size.width >= 700;

    // Scale factors for fonts and paddings to stay close to the reference UI
    final base = size.width.clamp(320, 1200);
    double sp(double n) => n * (base / 390); // tuned for iPhone width 390
    double gap(double n) => n * (base / 430);

    final sampleImage = 'https://images.unsplash.com/photo-1544441893-675973e31985?q=80&w=1200&auto=format&fit=crop';

    final priceNow = 112.0;
    final priceOld = 150.0;
    final stock = 5;

    Widget priceRow = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${priceNow.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: sp(24),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: gap(10)),
        Text(
          '\$${priceOld.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: sp(16),
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const Spacer(),
        Text(
          '$stock in stock',
          style: TextStyle(
            fontSize: sp(14),
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    Widget colorPicker = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: gap(8)),
        Text(
          'Choose Colors',
          style: TextStyle(
            fontSize: sp(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: gap(10)),
        Row(
          children: List.generate(_swatches.length, (i) {
            final selected = selectedColor == i;
            return Padding(
              padding: EdgeInsets.only(right: gap(10)),
              child: _ColorDot(
                color: _swatches[i],
                selected: selected,
                size: gap(28),
                onTap: () => setState(() => selectedColor = i),
              ),
            );
          }),
        ),
      ],
    );

    Widget actionsBar = Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: gap(14)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(gap(12)),
              ),
            ),
            child: Text(
              'ADD TO CART',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: sp(14),
              ),
            ),
          ),
        ),
        SizedBox(width: gap(12)),
        Expanded(
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: gap(14)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(gap(12)),
              ),
            ),
            child: Text(
              'BUY NOW',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: sp(14),
              ),
            ),
          ),
        ),
      ],
    );

    Widget imageCard = AspectRatio(
      aspectRatio: isTablet ? 1 : 1.2,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9E6),
              borderRadius: BorderRadius.circular(gap(18)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              sampleImage,
              fit: BoxFit.cover,
              loadingBuilder: (c, w, p) =>
              p == null ? w : const Center(child: CircularProgressIndicator()),
              errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image)),
            ),
          ),
          Positioned(
            right: gap(12),
            top: gap(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(gap(24)),
              onTap: () => setState(() => isFavorite = !isFavorite),
              child: Container(
                padding: EdgeInsets.all(gap(8)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: gap(12),
                      color: Colors.black.withOpacity(0.07),
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: sp(22),
                  color: isFavorite
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[700],
                ),
              ),
            ),
          )
        ],
      ),
    );

    Widget details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cotton Shirt',
          style: TextStyle(
            fontSize: sp(22),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: gap(4)),
        Text(
          'This is 100% cotton shirt.',
          style: TextStyle(fontSize: sp(14), color: Colors.grey[700]),
        ),
        SizedBox(height: gap(16)),
        priceRow,
        SizedBox(height: gap(18)),
        Text(
          'Description',
          style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.w600),
        ),
        SizedBox(height: gap(8)),
        Text(
          'This is 100% cotton wear shirt which is made by Bangladesh dummy text for layout preview. Breathable fabric, relaxed fit, and soft touch for all-day comfort.',
          style: TextStyle(
            fontSize: sp(14),
            height: 1.45,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: gap(16)),
        colorPicker,
        SizedBox(height: gap(20)),
        actionsBar,
      ],
    );

    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Tablet / Desktop: side-by-side content
            if (isTablet) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: gap(28), vertical: gap(18)),
                child: Column(
                  children: [
                    _TopBar(sp: sp, gap: gap),
                    SizedBox(height: gap(18)),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: imageCard),
                          SizedBox(width: gap(24)),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(right: gap(8)),
                                child: details,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Phone: stacked scroll
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        gap(16), gap(12), gap(16), gap(12)),
                    child: _TopBar(sp: sp, gap: gap),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: gap(16)),
                    child: imageCard,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        gap(16), gap(16), gap(16), gap(24)),
                    child: details,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.sp, required this.gap});

  final double Function(double) sp;
  final double Function(double) gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SoftIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.maybePop(context),
          size: gap(42),
        ),
        SizedBox(width: gap(12)),
        Expanded(
          child: Text(
            'Product Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sp(18),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: gap(12)),
        _SoftIconButton(
          icon: Icons.more_horiz_rounded,
          onTap: () {},
          size: gap(42),
        ),
      ],
    );
  }
}

class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({
    required this.icon,
    required this.onTap,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size),
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Icon(icon, size: size * 0.48),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.size,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? Border.all(
        color: Theme.of(context).colorScheme.primary, width: size * 0.12)
        : Border.all(color: Colors.black12);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 3),
            )
          ],
        ),
      ),
    );
  }
}

const _swatches = <Color>[
  Color(0xFF74CDD6), // light sky
  Color(0xFFFFC48C),
  Color(0xFF8CD6A7),
  Color(0xFFF3A5AE),
];