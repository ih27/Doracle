import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/dependency_injection.dart';
import '../global_key.dart';
import '../services/auth_service.dart';
import '../services/revenuecat_service.dart';
import '../services/user_service.dart';
import '../config/theme.dart';
import '../helpers/show_snackbar.dart';
import '../helpers/constants.dart';
import '../entities/entity_manager.dart';
import 'feedthedog_screen.dart';
import 'unlockallfeatures_screen.dart';
import '../services/unified_analytics_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onPurchaseComplete;

  const SettingsScreen({
    super.key,
    required this.onPurchaseComplete,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final UserService userService = getIt<UserService>();
  final AuthService authService = getIt<AuthService>();
  final RevenueCatService purchaseService = getIt<RevenueCatService>();
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermission();

    // Track screen view
    _analytics.logScreenView(screenName: 'settings_screen');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                letterSpacing: 0,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsItem(
              icon: Icons.lock_open,
              title: 'Unlock All Features',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnlockAllFeaturesScreen(),
                  ),
                );
              },
              color: AppTheme.yaleBlue,
              backgroundColor: AppTheme.naplesYellow,
              fontWeight: FontWeight.bold,
              arrowIcon: true,
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.diamond_rounded,
              title: 'Feed the Dog',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedTheDogScreen(
                      onPurchaseComplete: widget.onPurchaseComplete,
                    ),
                  ),
                );
              },
              color: AppTheme.secondaryColor,
              borderColor: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
              arrowIcon: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationToggle(),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.star,
              title: 'Rate Us',
              onTap: _handleRateUs,
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.share,
              title: 'Share with Friends',
              onTap: _handleShare,
            ),
            if (Platform.isIOS)
              Column(
                children: [
                  const SizedBox(height: 12),
                  _buildSettingsItem(
                    icon: Icons.restore_rounded,
                    title: 'Restore Purchase',
                    onTap: _handleRestore,
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleSignOut,
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Log Out'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _showDeleteAccountConfirmation,
              child: const Text(
                'Delete My Account',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(PurchaseTexts.termsOfServiceUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Text(
                PurchaseTexts.termsOfServiceText,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete your Account?'),
          backgroundColor: AppTheme.primaryBackground,
          content: const Text(
              'This action cannot be undone. All your data will be permanently deleted.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _handleAccountDeletion();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> _promptForPassword() async {
    String? password;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-enter Password'),
        backgroundColor: AppTheme.primaryBackground,
        content: TextField(
          obscureText: true,
          onChanged: (value) => password = value,
          decoration: const InputDecoration(hintText: "Enter your password"),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () => Navigator.of(context).pop(password),
          ),
        ],
      ),
    );
    return password;
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    Color? backgroundColor,
    Color? borderColor,
    FontWeight? fontWeight,
    bool arrowIcon = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? AppTheme.alternateColor,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
        ),
        trailing: arrowIcon
            ? Icon(Icons.chevron_right,
                color: color ?? Theme.of(context).primaryColor)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.alternateColor,
          width: 2,
        ),
      ),
      child: SwitchListTile.adaptive(
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        activeColor: AppTheme.secondaryColor,
        dense: false,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 0, 4, 0),
        value: _notificationsEnabled,
        onChanged: _handleNotifications,
        secondary: Icon(Icons.notifications_sharp,
            color: Theme.of(context).primaryColor),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await authService.signOut();
      if (!mounted) return;
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error signing out. Please try again.');
    }
  }

  // Shared function to clear only user's owner data
  Future<void> _clearUserData() async {
    // Only remove owner data, leave pets intact
    final OwnerManager ownerManager = getIt<OwnerManager>();
    await ownerManager.removeEntities();
  }

  // Handle successful account deletion
  void _handleSuccessfulDeletion() {
    if (!mounted) return;
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    showInfoSnackBar(navigatorKey.currentContext!,
        'Your account has been deleted successfully.');
  }

  // Handle authentication errors with specific provider messages
  void _handleAuthError(Object error) {
    if (!mounted) return;
    String errorMessage = 'Error deleting account';

    if (error.toString().contains('apple')) {
      errorMessage = 'Apple authentication failed. Please try again later.';
    } else if (error.toString().contains('google')) {
      errorMessage = 'Google authentication failed. Please try again later.';
    } else if (error.toString().contains('password')) {
      errorMessage = 'Password authentication failed. Please try again.';
    }

    showErrorSnackBar(context, errorMessage);
  }

  // Attempt to delete with provider-based reauthentication
  Future<void> _deleteWithReauthentication(String provider) async {
    try {
      await _clearUserData();
      await authService.reauthenticateAndDelete(provider);
      _handleSuccessfulDeletion();
    } catch (e) {
      _handleAuthError(e);
    }
  }

  Future<void> _handleAccountDeletion() async {
    try {
      // Try direct deletion first
      await _clearUserData();
      await authService.deleteUser();
      _handleSuccessfulDeletion();
    } on NeedsReauthenticationException catch (e) {
      // Handle password provider separately
      if (e.provider == 'password') {
        String? password = await _promptForPassword();
        if (password == null) {
          if (mounted) {
            showErrorSnackBar(
                context, 'Password is required for account deletion.');
          }
          return;
        }

        try {
          await _clearUserData();
          await authService.reauthenticateWithPasswordAndDelete(password);
          _handleSuccessfulDeletion();
        } catch (e) {
          _handleAuthError(e);
        }
      } else {
        // Handle other providers
        await _deleteWithReauthentication(e.provider);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Error deleting account: ${e.toString()}');
      }
    }
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _handleNotifications(bool value) async {
    // Attempt to open app settings
    bool didOpen = await openAppSettings();

    if (!didOpen) {
      // If we couldn't open settings, revert the toggle and show an error
      setState(() {
        _notificationsEnabled = !value;
      });
      if (mounted) {
        showErrorSnackBar(
            context, 'Unable to open settings. Please try again.');
      }
    }
    // If settings opened successfully, we don't update the state here
  }

  Future<void> _handleRateUs() async {
    final InAppReview inAppReview = InAppReview.instance;

    // Log rating event without awaiting it
    _analytics.logEvent(
      name: 'rate_app',
      parameters: {'content_type': 'app'},
    );

    await inAppReview.openStoreListing(appStoreId: '6504555731');
  }

  Future<void> _handleShare() async {
    await Share.share(SettingsScreenTexts.shareText,
        subject: SettingsScreenTexts.shareSubject);
  }

  Future<void> _handleRestore() async {
    if (await purchaseService.restorePurchase()) {
      debugPrint('Successfully restored a subscription from settings screen');
      if (!mounted) return;
      showInfoSnackBar(context, 'Subscription restored successfully.');
    } else {
      debugPrint('Restore  subscription failed in settings screen');
      if (!mounted) return;
      showErrorSnackBar(context, 'Subscription restore failed.');
    }
  }
}
