import '../controllers/purchases.dart';
import 'package:flutter/material.dart';
import '../dependency_injection.dart';
import '../helpers/price_utils.dart';
import '../helpers/show_snackbar.dart';
import '../services/user_service.dart';
import '../widgets/purchase_success_popup.dart';
import '../widgets/treat_card.dart';

class FeedTheDogScreen extends StatefulWidget {
  final VoidCallback onPurchaseComplete;

  const FeedTheDogScreen({
    super.key,
    required this.onPurchaseComplete,
  });

  @override
  FeedTheDogScreenState createState() => FeedTheDogScreenState();
}

class FeedTheDogScreenState extends State<FeedTheDogScreen> {
  final PurchasesController _purchasesController = getIt<PurchasesController>();
  final UserService _userService = getIt<UserService>();

  bool _isLoading = false;
  Map<String, String> _prices = {};

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    setState(() => _isLoading = true);
    _prices = await _purchasesController.fetchPrices();
    setState(() => _isLoading = false);
  }

  Future<void> _handlePurchase(int questionCount) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      //await Future.delayed(const Duration(seconds: 2));
      
      // initiate the purchase, return if it fails
      if (!await _purchasesController.purchasePackage(questionCount)) return;

      await _userService.updatePurchaseHistory(questionCount);

      // Call the callback to notify that a purchase was completed
      widget.onPurchaseComplete();

      // Navigate back to the fortune tell screen
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);

      setState(() {
        _isLoading = false;
      });

      // After successful purchase:
      showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return PurchaseSuccessPopup(
            questionCount: questionCount,
            onContinue: () {
              Navigator.of(buildContext).pop(); // Close the dialog
            },
          );
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      showErrorSnackBar(context, 'Purchase failed. Please try again.');
    }
  }

  Widget _buildLoadingOverlay() {
    return _isLoading
        ? Container(
            color: Theme.of(context).primaryColor.withOpacity(0.25),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Feed the Dog'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Text(
                  'Give Doracle treats to get more questions answered.',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    TreatCard(
                      treatSize: 'Small',
                      questionCount: 10,
                      originalPrice:
                          convertPrice(_prices['small_treat']) ?? '\$4.99',
                      discountedPrice: _prices['small_treat'] ?? '\$0.99',
                      description:
                          'Just a nibble! Keep the pup happy and keep the questions coming.',
                      onTap: () => _handlePurchase(10),
                    ),
                    TreatCard(
                      treatSize: 'Medium',
                      questionCount: 30,
                      originalPrice:
                          convertPrice(_prices['medium_treat']) ?? '\$9.99',
                      discountedPrice: _prices['medium_treat'] ?? '\$1.99',
                      description:
                          'A tasty snack! Your questions are his favorite treat.',
                      isHighlighted: true,
                      onTap: () => _handlePurchase(30),
                    ),
                    TreatCard(
                      treatSize: 'Large',
                      questionCount: 50,
                      originalPrice:
                          convertPrice(_prices['large_treat']) ?? '\$14.99',
                      discountedPrice: _prices['large_treat'] ?? '\$2.99',
                      description:
                          'A full meal! The oracle dog will be full and ready to reveal all!',
                      onTap: () => _handlePurchase(50),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildLoadingOverlay()
      ],
    );
  }
}
