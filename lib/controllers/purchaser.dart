import 'package:fortuntella/helpers/show_error.dart';
import 'package:fortuntella/models/product_item.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Purchases {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  //List<PurchaseDetails> _purchases = [];
  final BuildContext _context;

  Purchases(this._context) {
    _initialize();
  }

  void _initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    if (_isAvailable) {
      final purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _listenToPurchaseUpdated,
        onDone: () => _subscription.cancel(),
        onError: (error) {
          showErrorDialog(_context, "Purchase stream error: $error");
        },
      );
      _queryProducts();
    } else {
      showErrorDialog(_context, "In-app purchases are not available.");
    }
  }

  Future<void> _queryProducts() async {
    const Set<String> productIds = {'product_id_1', 'product_id_2'};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
    if (response.notFoundIDs.isNotEmpty) {
      showErrorDialog(_context, "Products not found: ${response.notFoundIDs}");
    } else {
      _products = response.productDetails;
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending state
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        _deliverProduct(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        showErrorDialog(_context, "Purchase error: ${purchaseDetails.error?.message}");
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> buyProduct(ProductItem productItem) async {
    try {
      final ProductDetails productDetails = _products.firstWhere((product) => product.id == productItem.id);
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      if (productItem.isConsumable) {
        _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      showErrorDialog(_context, "Failed to buy product: ${productItem.title}. Error: $e");
    }
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) {
    // Handle the delivery of the purchased product
    // This might include adding credits or unlocking features
  }

  List<ProductItem> getProductItems() {
    return _products.map((productDetails) => ProductItem.fromProductDetails(productDetails)).toList();
  }
}
