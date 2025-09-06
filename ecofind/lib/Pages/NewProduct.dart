import 'dart:io';
import 'dart:math';
import 'package:ecofind/Components/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Image handling
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  // Controllers
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _discountCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');
  final TextEditingController _yearCtrl = TextEditingController();
  final TextEditingController _brandCtrl = TextEditingController();
  final TextEditingController _modelCtrl = TextEditingController();
  final TextEditingController _lengthCtrl = TextEditingController();
  final TextEditingController _widthCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _skuCtrl = TextEditingController();

  // Toggles & selections
  String _category = 'Uncategorized';
  String _condition = 'Used';
  String _dimensionUnit = 'cm';
  String _weightUnit = 'kg';
  Color _pickedColor = Colors.blue;
  bool _originalPackaging = false;
  bool _manualIncluded = false;
  bool _featured = false;
  bool _freeShipping = true;
  bool _pickupAvailable = false;

  // Variants simple
  List<Map<String, String>> _variants = [];

  // Save state
  bool _isPublishing = false;
  bool _showSuccess = false;

  // Animation controllers
  late final AnimationController _buttonAnimController;

  @override
  void initState() {
    super.initState();
    _skuCtrl.text = _generateSKU();
    _buttonAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _buttonAnimController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    _qtyCtrl.dispose();
    _yearCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _skuCtrl.dispose();
    super.dispose();
  }

  String _generateSKU() {
    final prefix =
        (_brandCtrl.text.isNotEmpty ? _brandCtrl.text : 'PRD')
            .replaceAll(RegExp(r'\s+'), '')
            .toUpperCase();
    final rand = Random().nextInt(99999).toString().padLeft(5, '0');
    return '$prefix-$rand';
  }

  double _priceSafe() {
    final p = double.tryParse(_priceCtrl.text.replaceAll(',', '')) ?? 0.0;
    return p;
  }

  double _discountSafe() {
    final d = double.tryParse(_discountCtrl.text) ?? 0.0;
    return d.clamp(0.0, 100.0);
  }

  double _discountedPrice() {
    final p = _priceSafe();
    final d = _discountSafe();
    return p * (1 - d / 100);
  }

  double _savings() {
    return _priceSafe() - _discountedPrice();
  }

  Future<void> _pickImages() async {
    try {
      final results = await _picker.pickMultiImage(imageQuality: 75);
      if (results != null && results.isNotEmpty) {
        setState(() {
          _images.addAll(results);
        });
      }
    } catch (e) {
      // fallback single image
      final one = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (one != null) {
        setState(() => _images.add(one));
      }
    }
  }

  void _removeImageAt(int idx) {
    setState(() => _images.removeAt(idx));
  }

  void _addVariantRow() {
    setState(() {
      _variants.add({'name': '', 'value': ''});
    });
  }

  void _removeVariantAt(int idx) {
    setState(() => _variants.removeAt(idx));
  }

  void _saveDraft() {
    if (_formKey.currentState == null) return;
    // save to local DB or simply show toast for demo
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft saved locally')));
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix validation errors')),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    // animate button
    await _buttonAnimController.forward();
    await Future.delayed(const Duration(milliseconds: 600)); // mock upload time

    setState(() {
      _isPublishing = false;
      _showSuccess = true;
    });

    // success animation modal
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/lottie/success-confetti.json',
                      width: 160,
                      repeat: false,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Product published!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your product is now visible in My Listings.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // optionally navigate to My Listings
                      },
                      child: const Text('View Listing'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    // reset
    setState(() {
      _showSuccess = false;
      _skuCtrl.text = _generateSKU();
      _buttonAnimController.reset();
    });
  }

  void _openPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('Preview product'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              body: _buildPreviewContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_images.isNotEmpty)
            SizedBox(
              height: 260,
              child: PageView.builder(
                controller: PageController(viewportFraction: 1.0),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_images[index].path),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('No images')),
            ),
          const SizedBox(height: 12),
          Text(
            _titleCtrl.text.isEmpty ? 'Untitled product' : _titleCtrl.text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_descCtrl.text),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                currencyFmt.format(_discountedPrice()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (_discountSafe() > 0)
                Text(
                  currencyFmt.format(_priceSafe()),
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
              const Spacer(),
              if (_featured) Chip(label: Text('Featured')),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Category: $_category')),
              Chip(label: Text('Condition: $_condition')),
              Chip(
                label: Text('Color'),
                avatar: CircleAvatar(backgroundColor: _pickedColor),
              ),
              if (_originalPackaging) const Chip(label: Text('Original box')),
              if (_manualIncluded) const Chip(label: Text('Manual included')),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Specifications',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Brand: ${_brandCtrl.text.isEmpty ? '-' : _brandCtrl.text}'),
          Text('Model: ${_modelCtrl.text.isEmpty ? '-' : _modelCtrl.text}'),
          Text(
            'Dimensions: ${_lengthCtrl.text} x ${_widthCtrl.text} x ${_heightCtrl.text} $_dimensionUnit',
          ),
          Text('Weight: ${_weightCtrl.text} $_weightUnit'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _publish();
            },
            icon: const Icon(Icons.check),
            label: const Text('Publish from preview'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return AppBar(
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: primaryColor,
              padding: const EdgeInsets.all(6),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'EcoFinds Seller',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            'Add a new product',
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
        ],
      ),
      actions: [

        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/cart");
              },
              icon: const Icon(Icons.shopping_cart),
            ),
            Positioned(
              right: 10,
              top: 8,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: const Text(
                  '2',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Responsive layout builder: 1 column on narrow screens, two columns on wide
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useTwoColumns = width > 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Row(
          children: [

            const Text(
              'EcoFinds Seller',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),

          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/cart");
                  },
                icon: const Icon(Icons.shopping_cart),
              ),
              Positioned(
                right: 10,
                top: 8,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: const Text(
                    '2',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: AnimationLimiter(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  useTwoColumns
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // left: image + basic details
                          Expanded(
                            flex: 1,
                            child: ListView(
                              children: AnimationConfiguration.toStaggeredList(
                                duration: const Duration(milliseconds: 450),
                                childAnimationBuilder:
                                    (widget) => SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(child: widget),
                                    ),
                                children: [
                                  _buildImageCard(),
                                  const SizedBox(height: 12),
                                  _buildBasicDetailsCard(),
                                  const SizedBox(height: 12),
                                  _buildPricingStockCard(),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // right: specs, extras, shipping
                          Expanded(
                            flex: 1,
                            child: ListView(
                              children: AnimationConfiguration.toStaggeredList(
                                duration: const Duration(milliseconds: 450),
                                childAnimationBuilder:
                                    (widget) => SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(child: widget),
                                    ),
                                children: [
                                  _buildImageCard(),
                                  const SizedBox(height: 12),
                                  _buildBasicDetailsCard(),
                                  const SizedBox(height: 12),
                                  _buildPricingStockCard(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                      : ListView(
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 450),
                          childAnimationBuilder:
                              (widget) => SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(child: widget),
                              ),
                          children: [
                            _buildImageCard(),
                            const SizedBox(height: 12),
                            _buildBasicDetailsCard(),
                            const SizedBox(height: 12),
                            _buildPricingStockCard(),
                            const SizedBox(height: 12),
                            _buildSpecsCard(),
                            const SizedBox(height: 12),
                            _buildExtrasCard(),
                            const SizedBox(height: 12),
                            _buildShippingCard(),
                            const SizedBox(height: 12),
                            _buildVariantsCard(),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyActions(),
    );
  }

  // ---------------- UI cards ----------------

  Widget _cardWrapper({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }

  Widget _buildImageCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Images & Media',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_images.isEmpty)
            GestureDetector(
              onTap: _pickImages,
              child: DottedBox(
                child: Column(
                  children: const [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 44,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 6),
                    Text('Tap to add images (JPG/PNG)'),
                    Text('You can add multiple images, rearrange and remove'),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 260,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 1.0),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      final f = _images[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(f.path),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton(
                              onPressed: () => _removeImageAt(index),
                              icon: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.black45,
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add),
                      label: const Text('Add more'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Ideally reorder images - for demo just clear
                        setState(
                          () =>
                              _images.sort((a, b) => a.name.compareTo(b.name)),
                        );
                      },
                      icon: const Icon(Icons.reorder),
                      label: const Text('Reorder'),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBasicDetailsCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Product title'),
            validator:
                (v) =>
                    (v == null || v.trim().length < 3)
                        ? 'Enter a valid title'
                        : null,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _category,
            items:
                [
                      'Uncategorized',
                      'Clothing',
                      'Electronics',
                      'Home',
                      'Books',
                      'Sports',
                      'Furniture',
                    ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Uncategorized'),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Explain condition, usage, and advantages...',
            ),
            maxLines: 5,
            minLines: 3,
            validator:
                (v) =>
                    (v == null || v.trim().length < 10)
                        ? 'Please add a description'
                        : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingStockCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing & Stock',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (MRP)'),
                  validator:
                      (v) =>
                          (v == null ||
                                  double.tryParse(v.replaceAll(',', '')) ==
                                      null)
                              ? 'Enter price'
                              : null,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _discountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Discount %'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'You will receive: ',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(width: 8),
              Text(
                currencyFmt.format(_discountedPrice()),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (_discountSafe() > 0)
                Text(
                  '(Save ${currencyFmt.format(_savings())})',
                  style: const TextStyle(color: Colors.green),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity in stock',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _condition,
                  onChanged: (v) => setState(() => _condition = v ?? 'Used'),
                  items:
                      ['New', 'Like New', 'Used', 'Refurbished']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  decoration: const InputDecoration(labelText: 'Condition'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _brandCtrl,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  onChanged: (_) {
                    setState(() {
                      _skuCtrl.text = _generateSKU();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _modelCtrl,
                  decoration: const InputDecoration(labelText: 'Model'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _lengthCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Length'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _widthCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Width'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Height'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              DropdownButton<String>(
                value: _dimensionUnit,
                onChanged: (v) => setState(() => _dimensionUnit = v ?? 'cm'),
                items:
                    ['cm', 'inches']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight'),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _weightUnit,
                onChanged: (v) => setState(() => _weightUnit = v ?? 'kg'),
                items:
                    ['kg', 'g', 'lb']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Color: '),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showColorPicker(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _pickedColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black26),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _yearCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year of manufacture (optional)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _skuCtrl,
            decoration: const InputDecoration(
              labelText: 'SKU (auto-generated)',
            ),
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildExtrasCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Packaging & Extras',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              FilterChip(
                label: const Text('Original packaging'),
                selected: _originalPackaging,
                onSelected: (v) => setState(() => _originalPackaging = v),
              ),
              FilterChip(
                label: const Text('Manual / instructions'),
                selected: _manualIncluded,
                onSelected: (v) => setState(() => _manualIncluded = v),
              ),
              FilterChip(
                label: const Text('Featured listing'),
                selected: _featured,
                onSelected: (v) => setState(() => _featured = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping & Logistics',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Free shipping'),
            value: _freeShipping,
            onChanged: (v) => setState(() => _freeShipping = v),
          ),
          SwitchListTile(
            title: const Text('Pickup available'),
            value: _pickupAvailable,
            onChanged: (v) => setState(() => _pickupAvailable = v),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Pickup / Dispatch Time (e.g., 2-3 business days)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantsCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Variants (optional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < _variants.length; i++)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _variants[i]['name'],
                    onChanged: (v) => _variants[i]['name'] = v,
                    decoration: const InputDecoration(
                      labelText: 'Attribute name (e.g., Color)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _variants[i]['value'],
                    onChanged: (v) => _variants[i]['value'] = v,
                    decoration: const InputDecoration(
                      labelText: 'Value (e.g., Red)',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeVariantAt(i),
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addVariantRow,
            icon: const Icon(Icons.add),
            label: const Text('Add variant'),
          ),
        ],
      ),
    );
  }

  // bottom sticky actions: Save draft, Preview, Publish
  Widget _buildStickyActions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Row(
          children: [

            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _openPreview,
              style: ElevatedButton.styleFrom(minimumSize: const Size(140, 52),backgroundColor: primaryColor),
              child: const Text('Preview', style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(width: 12),
            ScaleTransition(
              scale: Tween(
                begin: 1.0,
                end: 0.96,
              ).animate(_buttonAnimController),
              child: FilledButton(
                onPressed: _isPublishing ? null : _publish,
                style: FilledButton.styleFrom(minimumSize: const Size(160, 52), backgroundColor: primaryColor),
                child:
                    _isPublishing
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Publishing...'),
                          ],
                        )
                        : const Text('Add Item', style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Pick color'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: _pickedColor,
                onColorChanged: (c) => setState(() => _pickedColor = c),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

// Small dotted placeholder widget
class DottedBox extends StatelessWidget {
  final Widget child;

  const DottedBox({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
        color: Colors.grey.shade50,
      ),
      child: Center(child: child),
    );
  }
}
