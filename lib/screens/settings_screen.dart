import 'package:flutter/material.dart';
import '../auth_wrapper.dart';
import '../theme.dart';
import '../helpers/show_snackbar.dart';
import 'purchase_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Roboto',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsItem(
              icon: Icons.diamond_rounded,
              title: 'Feed the Dog',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedTheDogScreen()),
                );
              },
              color: AppTheme.getColorFromHex("#0d3b66"),
              backgroundColor: AppTheme.getColorFromHex("#f4d35e"),
              fontWeight: FontWeight.bold,
              arrowIcon: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationToggle(),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.star,
              title: 'Rate Us',
              onTap: () {
                // TODO: Implement rate us functionality
              },
            ),
            const SizedBox(height: 12),
            _buildSettingsItem(
              icon: Icons.share,
              title: 'Share with Friends',
              onTap: () {
                // TODO: Implement share functionality
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => handleSignOut(context),
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
              onPressed: () {
                // TODO: Implement delete account functionality
                showErrorSnackBar(context, 'Account deletion not implemented');
              },
              child: const Text(
                'Delete My Account',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const Spacer(), // This will push the Terms and Conditions to the bottom
            TextButton(
              onPressed: () {
                // TODO: Show terms and conditions
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Terms and Conditions'),
                      content: const Text(
                          'Our terms and conditions will be displayed here.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                'Terms and Conditions',
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

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    Color? backgroundColor,
    FontWeight? fontWeight,
    bool arrowIcon = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getColorFromHex("#ede8df"),
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
          color: AppTheme.getColorFromHex("#ede8df"),
          width: 2,
        ),
      ),
      child: SwitchListTile.adaptive(
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        activeColor: AppTheme.getColorFromHex("#18aa99"),
        dense: false,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 0, 4, 0),
        value: _notificationsEnabled,
        onChanged: (bool value) {
          setState(() {
            _notificationsEnabled = value;
          });
          // TODO: Implement notification toggle functionality
        },
        secondary: Icon(Icons.notifications_sharp,
            color: Theme.of(context).primaryColor),
      ),
    );
  }
}
