# Meta Performance Marketing Integration Guide for Doracle

This guide explains how to set up and use Meta (Facebook) performance marketing tools with the Doracle app. The integration enables you to track app events and create targeted advertising campaigns on Meta platforms.

## Prerequisites

1. A Facebook Business Account
2. A Meta Ads Manager account
3. Access to the Facebook Developer portal

## Setup Instructions

### 1. Create a Facebook App

1. Go to [Facebook Developers](https://developers.facebook.com/) and sign in with your Facebook account
2. Click "My Apps" → "Create App"
3. Select "Business" as the app type
4. Enter app details (name, contact email, etc.) and create the app
5. Under "Add Products to Your App", find and set up "Facebook Login" and "Meta SDK"

### 2. Get Your App ID and Client Token

1. Navigate to your app dashboard in Facebook Developers
2. Go to Settings → Basic
3. Note your App ID and Client Token (you'll need these for the next steps)

### 3. Configure Your Flutter App

#### Android Configuration

1. Update the `android/app/src/main/res/values/strings.xml` file with your Facebook App ID and Client Token:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
    <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
    <string name="app_name">Doracle</string>
</resources>
```

2. Make sure your `AndroidManifest.xml` includes the meta-data tags:

```xml
<application ...>
    <!-- Facebook SDK Meta-data -->
    <meta-data
        android:name="com.facebook.sdk.ApplicationId"
        android:value="@string/facebook_app_id"/>
    <meta-data
        android:name="com.facebook.sdk.ClientToken"
        android:value="@string/facebook_client_token"/>
    <!-- Other meta-data -->
</application>
```

#### iOS Configuration

1. Update the `ios/Runner/Info.plist` file with your Facebook App ID and Client Token:

```xml
<key>FacebookAppID</key>
<string>YOUR_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>Doracle</string>
<key>CFBundleURLTypes</key>
<array>
    <!-- Existing entries -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fbYOUR_FACEBOOK_APP_ID</string>
        </array>
    </dict>
</array>
```

Replace `YOUR_FACEBOOK_APP_ID` and `YOUR_FACEBOOK_CLIENT_TOKEN` with the values from your Facebook Developer dashboard.

### 4. App Tracking Transparency (iOS)

For iOS 14.5 and above, Apple requires apps to request permission before tracking users. In Doracle, this is already implemented through the `permission_handler` package and integrated with both Analytics Service and Facebook App Events Service.

The user will see a permission dialog with this message:
```
We use your data to provide personalized fortune readings and improve our mystical services. This helps us offer a better experience tailored to your spiritual journey.
```

### 5. Events Already Tracked

The following events are already implemented in the Doracle app:

1. **App Launch** (`fb_mobile_activate_app`): Tracked when the app is opened
2. **Registration Completion** (`fb_mobile_complete_registration`): When a user completes registration
3. **Content Views** (`fb_mobile_content_view`): When a user views a fortune reading
4. **Purchases** (`purchase`): When a user buys question packs or subscriptions
5. **Subscriptions** (`fb_mobile_subscription`): When a user subscribes to a service

## Using the Facebook App Events Service

The `FacebookAppEventsService` is already integrated with your app. If you need to track additional events in your own code, use the service as follows:

```dart
import 'package:get_it/get_it.dart';
import '../services/facebook_app_events_service.dart';

// Get the service
final facebookEvents = GetIt.instance<FacebookAppEventsService>();

// Track a standard event
facebookEvents.logCompleteRegistration(registrationMethod: 'email');

// Track a purchase event
facebookEvents.logPurchase(
  amount: 9.99,
  currency: 'USD',
  parameters: {'product_name': 'premium_questions'}
);

// Track a custom event
facebookEvents.logCustomEvent(
  eventName: 'shared_fortune',
  parameters: {'fortune_type': 'daily_horoscope'}
);

// Set user data for better targeting
facebookEvents.setUserData(
  email: 'user@example.com',
  firstName: 'John',
  lastName: 'Doe'
);

// Clear user data (for compliance with privacy regulations)
facebookEvents.clearUserData();
```

## Setting Up Meta Ads Manager Campaigns

Once your app is configured and events are being tracked, you can set up marketing campaigns in Meta Ads Manager:

1. Go to [Meta Ads Manager](https://business.facebook.com/adsmanager)
2. Click "Create" to start a new campaign
3. Select a campaign objective (e.g., App Installs, Conversions)
4. Configure your audience, placements, budget, and schedule
5. In the ad setup, select your app and choose which events to optimize for
6. Complete the campaign setup and launch your ads

## Best Practices

1. **Event Naming**: Use consistent naming conventions for custom events
2. **Test Events**: Use the Facebook Events Manager to verify events are being received correctly
3. **GDPR/Privacy Compliance**: 
   - Always clear user data when the user logs out
   - Use LDU (Limited Data Use) for users who don't grant tracking permission
   - Make sure your privacy policy covers Meta data usage
4. **Campaign Optimization**: Start with broader targeting and refine based on performance data
5. **Creative Testing**: A/B test different ad creatives to find what resonates with your audience
6. **Advanced Matching**: Set user data parameters for better conversion tracking

## Troubleshooting

- **Events Not Showing**: It can take up to 24 hours for events to appear in Facebook Analytics
- **Debug Mode**: Use Facebook's Events Manager Test Events feature during development
- **SDK Initialization**: Ensure the SDK is properly initialized before logging events
- **User Tracking Permission**: Make sure your app properly handles ATT permissions on iOS

## Additional Resources

- [Facebook App Events Documentation](https://developers.facebook.com/docs/app-events/)
- [Meta Ads Manager Guide](https://www.facebook.com/business/help/282701548912119)
- [Meta Privacy Requirements](https://developers.facebook.com/docs/app-events/guides/limited-data-use/)
- [App Tracking Transparency Guide](https://developer.apple.com/documentation/apptrackingtransparency) 