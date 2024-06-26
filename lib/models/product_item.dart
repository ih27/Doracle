import 'package:in_app_purchase/in_app_purchase.dart';

class ProductItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final bool isConsumable;

  ProductItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.isConsumable,
  });

  factory ProductItem.fromProductDetails(ProductDetails productDetails) {
    return ProductItem(
      id: productDetails.id,
      title: productDetails.title,
      description: productDetails.description,
      price: productDetails.price,
      isConsumable: productDetails.id.startsWith('consumable_'), // Example condition
    );
  }
}
