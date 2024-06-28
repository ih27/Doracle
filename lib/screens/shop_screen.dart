import 'package:flutter/material.dart';
import 'package:fortuntella/controllers/purchaser.dart';
import 'package:fortuntella/models/product_item.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Purchases _purchases;
  List<ProductItem> _productItems = [];

  @override
  void initState() {
    super.initState();
    _purchases = Purchases(context);
    _loadProducts();
  }

  void _loadProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _productItems = _purchases.getProductItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          const Text(
            'Welcome to the shop!',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _productItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _productItems.length,
                    itemBuilder: (context, index) {
                      final product = _productItems[index];
                      return ListTile(
                        title: Text(product.title),
                        subtitle: Text(product.description),
                        trailing: ElevatedButton(
                          onPressed: () => _purchases.buyProduct(product),
                          child: Text(product.price),
                        ),
                      );
                    },
                  ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
