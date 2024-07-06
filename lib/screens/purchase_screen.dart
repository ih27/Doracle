import 'package:flutter/material.dart';

import '../dependency_injection.dart';
import '../services/user_service.dart';
import '../theme.dart';
import 'purchase_success_popup.dart';

class FeedTheDogScreen extends StatelessWidget {
  final VoidCallback onPurchaseComplete;

  const FeedTheDogScreen({
    super.key,
    required this.onPurchaseComplete,
  });

  Future<void> _handlePurchase(BuildContext context, int questionCount) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PurchaseConfirmationDialog();
      },
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final userService = getIt<UserService>();
    await userService.updatePurchaseHistory(questionCount);

    if (!context.mounted) return;
    Navigator.of(context).pop(); // Dismiss the loading dialog

    // Call the callback to notify that a purchase was completed
    onPurchaseComplete();

    // Navigate back to the fortune tell screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsetsDirectional.fromSTEB(24, 4, 0, 0),
            child: Text('Give Doracle treats to get more questions answered.',
                style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSmallTreatCard(context),
                  _buildMediumTreatCard(context),
                  _buildLargeTreatCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTreatCard(BuildContext context) {
    return GestureDetector(
        onTap: () => _handlePurchase(context, 10),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: Container(
            width: double.infinity,
            height: 200,
            constraints: const BoxConstraints(
              maxWidth: 570,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(100),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(100),
              ),
              border: Border.all(
                color: AppTheme.accent1,
                width: 5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Small Treat',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Roboto',
                                    letterSpacing: 0,
                                  ),
                        ),
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            child: Text(
                              'Just a nibble! Keep the pup happy and keep the questions coming.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontFamily: 'Roboto',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.accent2,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              alignment: const AlignmentDirectional(0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '10',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            fontFamily: 'Roboto',
                                            color: AppTheme.yaleBlue,
                                            fontSize: 30,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'questions',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontFamily: 'Roboto',
                                            color: AppTheme.primaryColor,
                                            fontSize: 14,
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    25, 0, 0, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '\$4.99',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontFamily: 'Roboto',
                                              color: AppTheme.error,
                                              letterSpacing: 0,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: AppTheme.error,
                                            ),
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '\$0.99',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              fontFamily: 'Roboto',
                                              color: AppTheme.success,
                                              fontSize: 36,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.accent1,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(100),
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(100),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'BUY',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontFamily: 'Roboto',
                                  color: AppTheme.yaleBlue,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Small Treat',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'Roboto',
                                      color: AppTheme.yaleBlue,
                                      letterSpacing: 0,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildMediumTreatCard(BuildContext context) {
    return GestureDetector(
        onTap: () => _handlePurchase(context, 30),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: Container(
            width: double.infinity,
            height: 200,
            constraints: const BoxConstraints(
              maxWidth: 570,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lemonChiffon,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(100),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(100),
              ),
              border: Border.all(
                color: AppTheme.sandyBrown,
                width: 5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medium Treat',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Roboto',
                                    letterSpacing: 0,
                                  ),
                        ),
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            child: Text(
                              'A tasty snack! Your questions are his favorite treat.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontFamily: 'Roboto',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              alignment: const AlignmentDirectional(0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '30',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            fontFamily: 'Roboto',
                                            color: AppTheme.primaryBackground,
                                            fontSize: 35,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'questions',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontFamily: 'Roboto',
                                            color: AppTheme.alternateColor,
                                            fontSize: 14,
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    25, 0, 0, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '\$9.99',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontFamily: 'Roboto',
                                              color: AppTheme.error,
                                              letterSpacing: 0,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: AppTheme.error,
                                            ),
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '\$1.99',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              fontFamily: 'Roboto',
                                              color: AppTheme.success,
                                              fontSize: 36,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      width: 100,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 4,
                                            color: AppTheme.success,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppTheme.tomato,
                                            AppTheme.sandyBrown
                                          ],
                                          stops: [0, 1],
                                          begin: AlignmentDirectional(0, 1),
                                          end: AlignmentDirectional(0, -1),
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      alignment:
                                          const AlignmentDirectional(0, 0),
                                      child: Text(
                                        'Best Value',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontFamily: 'Roboto',
                                              color: AppTheme.primaryBackground,
                                              fontSize: 16,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  height: 200,
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                  ),
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0xFF540E00),
                        offset: Offset(2, 2),
                      )
                    ],
                    gradient: LinearGradient(
                      colors: [AppTheme.sandyBrown, Color(0xFFFFBF89)],
                      stops: [0, 1],
                      begin: AlignmentDirectional(-1, 0),
                      end: AlignmentDirectional(1, 0),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(100),
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(100),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'BUY',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontFamily: 'Roboto',
                                  color: AppTheme.yaleBlue,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Medium Treat',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontFamily: 'Roboto',
                                      color: AppTheme.yaleBlue,
                                      letterSpacing: 0,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildLargeTreatCard(BuildContext context) {
    return GestureDetector(
        onTap: () => _handlePurchase(context, 50),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: Container(
            width: double.infinity,
            height: 200,
            constraints: const BoxConstraints(
              maxWidth: 570,
            ),
            decoration: BoxDecoration(
              color: AppTheme
                  .primaryBackground, // Assuming this is the default background color
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(100),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(100),
              ),
              border: Border.all(
                color: AppTheme.accent1,
                width: 5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Large Treat',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Roboto',
                                    letterSpacing: 0,
                                  ),
                        ),
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.5,
                            ),
                            child: Text(
                              'A full meal! The oracle dog will be full and ready to reveal all!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontFamily: 'Roboto',
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppTheme.accent2,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              alignment: const AlignmentDirectional(0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '50',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            fontFamily: 'Roboto',
                                            color: AppTheme.yaleBlue,
                                            fontSize: 40,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'questions',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontFamily: 'Roboto',
                                            color: AppTheme.primaryColor,
                                            fontSize: 14,
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    25, 0, 0, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '\$14.99',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontFamily: 'Roboto',
                                              color: AppTheme.error,
                                              letterSpacing: 0,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: AppTheme.error,
                                            ),
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '\$2.99',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              fontFamily: 'Roboto',
                                              color: AppTheme.success,
                                              fontSize: 36,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  height: 200,
                  constraints: const BoxConstraints(
                    maxWidth: 200,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent1,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(100),
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(100),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'BUY',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Roboto',
                                    color: AppTheme.yaleBlue,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Large Treat',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'Roboto',
                                    color: AppTheme.yaleBlue,
                                    letterSpacing: 0,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
