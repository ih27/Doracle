import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../controllers/purchases.dart';
import '../helpers/show_snackbar.dart';
import '../helpers/constants.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Package> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    _packages = await PurchasesController.fetchPackages();
    setState(() => _isLoading = false);
  }

  Future<void> _handlePurchase(Package package) async {
    setState(() => _isLoading = true);
    bool success = await PurchasesController.purchasePackage(context, package);
    setState(() => _isLoading = false);
    if (success) {
      if (!mounted) return;
      showInfoSnackBar(context, InfoMessages.purchaseSuccess);
      // Optionally refresh packages or update UI
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    bool success = await PurchasesController.restorePurchases(context);
    setState(() => _isLoading = false);
    if (success) {
      if (!mounted) return;
      showInfoSnackBar(context, InfoMessages.restoreSuccess);
      // Optionally refresh packages or update UI
    } else {
      if (!mounted) return;
      showInfoSnackBar(context, InfoMessages.restoreFail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _packages.isEmpty
              ? const Center(child: Text('No packages available'))
              : ListView.builder(
                  itemCount: _packages.length,
                  itemBuilder: (context, index) {
                    Package package = _packages[index];
                    return ListTile(
                      title: Text(package.storeProduct.title),
                      subtitle: Text(package.storeProduct.description),
                      trailing: Text(package.storeProduct.priceString),
                      onTap: () => _handlePurchase(package),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleRestore,
        tooltip: 'Restore Purchases',
        child: const Icon(Icons.restore),
      ),
    );
  }
}
