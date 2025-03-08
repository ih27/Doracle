# Analytics Configuration and Migration Guide

## Part 1: Analytics Events Configuration

This document outlines all the analytics events used in the Doracle app across Firebase Analytics, Facebook App Events, and Adjust. Use this guide to set up your analytics dashboards and ensure proper event tracking.

### Event Usage Overview

| Event Type | Firebase Analytics | Facebook App Events | Adjust | App Location |
|------------|-------------------|---------------------|--------|--------------|
| App Open | Built-in | Built-in (fb_mobile_activate_app) | N/A | Initialization |
| Screen View | Built-in | Custom (content_view) | N/A | All screens |
| User Registration | Built-in | Built-in (fb_mobile_complete_registration) | Custom | Registration flow |
| User Login | Built-in | Custom | Custom | Login flow |
| Purchase | Built-in | Built-in | Built-in | Treats purchase |
| Subscription | Custom | Built-in | Built-in | Subscription screens |
| Rating App | Custom | Custom | Custom | Settings screen |
| Location Search | Custom | Custom | Custom | Map overlay |
| Tutorial Complete | Custom | Custom | Custom | Onboarding |

### Detailed Event Configuration

#### 1. Screen Views

**Firebase Analytics:**
- Event Name: `screen_view` (built-in)
- Parameters:
  - `screen_name`: The name of the screen (e.g., "home_screen", "settings_screen")
  
**Facebook App Events:**
- Event Name: `fb_mobile_content_view` (custom implementation)
- Parameters:
  - `content_type`: "screen"
  - `content_id`: Screen name (e.g., "fortune_screen")

**Adjust:**
- Not tracked directly

**App Location:** All screen files (home_screen.dart, settings_screen.dart, etc.)

#### 2. User Registration

**Firebase Analytics:**
- Event Name: `sign_up` (built-in)
- Parameters:
  - `method`: Registration method (e.g., "email", "apple", "google")

**Facebook App Events:**
- Event Name: `fb_mobile_complete_registration` (built-in)
- Parameters:
  - `registration_method`: Registration method

**Adjust:**
- Event Name: Requires a custom event token
- Parameters:
  - `method`: Registration method
- [ ] Create custom Adjust event token for registration (recommended for attribution)
- [ ] Update app_manager.dart with token from AdjustEvents.registration

**App Location:** app_manager.dart

#### 3. User Login

**Firebase Analytics:**
- Event Name: `login` (built-in)
- Parameters:
  - `method`: Login method (e.g., "email", "apple", "google")

**Facebook App Events:**
- Event Name: `Login` (custom)
- Parameters:
  - `method`: Login method
- [ ] Create custom Facebook event for login

**Adjust:**
- Event Name: Requires a custom event token
- Parameters:
  - `method`: Login method
- [ ] Create custom Adjust event token for login (optional)
- [ ] Update app_manager.dart with token from AdjustEvents.login

**App Location:** app_manager.dart

#### 4. Purchases (Treats)

**Firebase Analytics:**
- Event Name: `purchase` (built-in for numeric prices, custom for string prices)
- Parameters:
  - `price_string`: Price as string
  - `product_id`: Product identifier
  - `question_count`: Number of questions purchased

**Facebook App Events:**
- Method: `logPurchaseWithPriceString` (built-in)
- Parameters:
  - `priceString`: Price as string
  - `productIdentifier`: Product identifier
  - `question_count`: Number of questions purchased

**Adjust:**
- Event Type: Revenue tracking (built-in)
- Parameters:
  - `price`: Numeric price extracted from price string
  - `currency`: "USD" (default)
  - `product_id`: Product identifier
  - `price_string`: Price as string
  - `question_count`: Number of questions purchased
- [ ] Create custom Adjust revenue event token for purchases (important for conversion tracking)
- [ ] Update feedthedog_screen.dart with token from AdjustEvents.purchase

**App Location:** feedthedog_screen.dart

#### 5. Subscriptions

**Firebase Analytics:**
- Event Name: `subscription_purchase` (custom)
- Parameters:
  - `subscription_id`: Subscription identifier
  - `price_string`: Price as string (if available)
- [ ] Create custom Firebase event for subscription_purchase

**Facebook App Events:**
- Method: `logSubscribeWithPriceString` (built-in)
- Parameters:
  - `subscriptionId`: Subscription identifier
  - `priceString`: Price as string

**Adjust:**
- Event Type: Revenue tracking (built-in)
- Parameters:
  - `subscription_id`: Subscription identifier
  - `price_string`: Price as string
  - Additional custom parameters (e.g., `plan_id` for assessment plans)
- [ ] Create custom Adjust revenue event token for subscriptions (important for conversion tracking)
- [ ] Update unlockallfeatures_screen.dart and iap_utils.dart with token from AdjustEvents.subscription

**App Location:** unlockallfeatures_screen.dart, assessment_screen.dart, iap_utils.dart

#### 6. Rating App

**Firebase Analytics:**
- Event Name: `rate_app` (custom)
- Parameters:
  - `content_type`: "app"
- [ ] Create custom Firebase event for rate_app

**Facebook App Events:**
- Event Name: `rate_app` (custom)
- Parameters:
  - `content_type`: "app"
- [ ] Create custom Facebook event for rate_app

**Adjust:**
- Requires a custom event token (if needed)
- Parameters:
  - `content_type`: "app"
- [ ] Create custom Adjust event token for rating (optional)
- [ ] Update settings_screen.dart with token from AdjustEvents.rateApp if needed

**App Location:** settings_screen.dart

#### 7. Location Search

**Firebase Analytics:**
- Event Name: `location_search` (custom)
- Parameters:
  - `search_string`: Search term
  - `content_type`: "location"
- [ ] Create custom Firebase event for location_search

**Facebook App Events:**
- Event Name: `location_search` (custom)
- Parameters:
  - `search_string`: Search term
  - `content_type`: "location"
- [ ] Create custom Facebook event for location_search

**Adjust:**
- Requires a custom event token (if needed)
- Parameters:
  - `search_string`: Search term
  - `content_type`: "location"
- [ ] Create custom Adjust event token for location search (optional)
- [ ] Update map_overlay.dart with token from AdjustEvents.locationSearch if needed

**App Location:** map_overlay.dart

#### 8. Tutorial Completion

**Firebase Analytics:**
- Event Name: `tutorial_complete` (custom)
- Parameters:
  - `method`: Completion method (e.g., "normal")
- [ ] Create custom Firebase event for tutorial_complete

**Facebook App Events:**
- Event Name: `tutorial_complete` (custom)
- Parameters:
  - `method`: Completion method
- [ ] Create custom Facebook event for tutorial_complete

**Adjust:**
- Requires a custom event token (if needed)
- Parameters:
  - `method`: Completion method
- [ ] Create custom Adjust event token for tutorial completion (recommended for conversion tracking)
- [ ] Update app_manager.dart with token from AdjustEvents.tutorialComplete

**App Location:** app_manager.dart

### Configuration Steps for Each Platform

#### Firebase Analytics

1. [ ] Create the following custom event definitions in Firebase Analytics:
   - [ ] `subscription_purchase`
   - [ ] `rate_app`
   - [ ] `location_search`
   - [ ] `tutorial_complete`
2. [ ] Verify built-in events are being tracked correctly

#### Facebook App Events

1. [ ] Ensure your Facebook SDK is correctly configured with your App ID and Client Token
2. [ ] Create custom event definitions in Facebook Analytics for:
   - [ ] `Login`
   - [ ] `rate_app`
   - [ ] `location_search`
   - [ ] `tutorial_complete`
3. [ ] Verify built-in events are working properly

#### Adjust

1. [ ] Create custom event tokens in the Adjust dashboard:
   - [ ] User Registration (important for attribution) - Save token to AdjustEvents.registration
   - [ ] User Login (optional) - Save token to AdjustEvents.login
   - [ ] Purchases (important for conversion) - Save token to AdjustEvents.purchase
   - [ ] Subscriptions (important for conversion) - Save token to AdjustEvents.subscription
   - [ ] Tutorial Completion (recommended) - Save token to AdjustEvents.tutorialComplete
   - [ ] App Rating (optional) - Save token to AdjustEvents.rateApp
   - [ ] Location Search (optional) - Save token to AdjustEvents.locationSearch

2. [ ] For iOS, configure SKAdNetwork conversion values in Adjust dashboard:
   - [ ] Registration: conversion value 2
   - [ ] Tutorial completion: conversion value 1
   - [ ] Purchase: conversion value 4
   - [ ] Subscription: conversion value 6
   
3. [ ] Update AdjustEvents class constants with actual tokens
4. [ ] Enable revenue tracking for purchase and subscription events

**Note**: Unlike Firebase and Facebook, Adjust tracking is selective. You only need to create tokens and add tracking for events relevant to your attribution and conversion goals. When no token is provided to the UnifiedAnalyticsService, the event will still be tracked in Firebase and Facebook but not in Adjust.

### Using the Event Tokens in Code

A constants file `lib/config/adjust_config.dart` has been created with placeholder tokens. After setting up events in the Adjust dashboard, update this file with your actual event tokens. The UnifiedAnalyticsService will automatically use these tokens internally - you don't need to reference them in your code.

For example, when you call:

```dart
// In your screen or component:
_analytics.logPurchaseWithPriceString(
  priceString: price,
  productIdentifier: packageId,
  parameters: {'question_count': questionCount.toString()},
);
```

The service will automatically use the appropriate token (in this case, `AdjustEvents.purchase`) to track the event in Adjust.

This approach keeps your analytics implementation clean and consistent while hiding the implementation details from the rest of your codebase.

### Non-Blocking Analytics Calls

All analytics calls in the UnifiedAnalyticsService are designed to be non-blocking (fire-and-forget). This means:

1. You should NOT use `await` when calling analytics methods
2. Analytics operations run in the background and won't slow down your app
3. Any analytics failures are caught internally and won't affect app functionality

Example of correct usage:

```dart
// Correct - non-blocking
_analytics.logPurchaseWithPriceString(
  priceString: price,
  productIdentifier: packageId,
  parameters: {'question_count': questionCount.toString()},
);

// Continue with app logic immediately
showSuccessScreen();
```

Example of incorrect usage:

```dart
// Incorrect - don't use await, it's unnecessary
await _analytics.logPurchaseWithPriceString(...); // Don't do this
```

This design ensures analytics never becomes a bottleneck in your app's performance.

## Part 2: Analytics Migration Guide

### Overview

This section describes how to migrate from using individual analytics services (Firebase Analytics, Facebook App Events, and Adjust) to using the new unified analytics service that wraps all three.

The UnifiedAnalyticsService provides a simplified interface for tracking events, ensuring that all events are consistently tracked across all three analytics platforms simultaneously with less code.

### Migration Checklist

- [ ] Update imports to use UnifiedAnalyticsService
- [ ] Replace individual service dependencies with UnifiedAnalyticsService
- [ ] Update event tracking calls
- [ ] Add Adjust event tokens from AdjustEvents class for key events
- [ ] Update initialization in main.dart
- [ ] Test that all events are being sent to all platforms

### Benefits

- **Simplified API**: Track events once instead of in multiple places
- **Consistent data**: Ensure the same event data is sent to all services
- **Reduced code duplication**: Less repetitive code for tracking the same events
- **Easier maintenance**: Centralized analytics logic makes future changes easier
- **Non-blocking**: All analytics calls are non-blocking (fire-and-forget), ensuring they don't impact app performance or user experience

### How to Migrate

#### Step 1: Update Imports

Change your imports from individual analytics services to the unified service:

```dart
// Before
import 'services/analytics_service.dart';
import 'services/facebook_app_events_service.dart';
import 'services/adjust_service.dart';

// After
import 'services/unified_analytics_service.dart';
import 'config/adjust_config.dart';  // For Adjust event tokens
```

#### Step 2: Update Service Dependency

Replace individual service dependencies with the unified service:

```dart
// Before
final AnalyticsService _analytics = getIt<AnalyticsService>();
final FacebookAppEventsService _facebookEvents = getIt<FacebookAppEventsService>();
final AdjustService _adjustService = getIt<AdjustService>();

// After
final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();
```

#### Step 3: Replace Event Tracking Calls

##### Basic Event Tracking

```dart
// Before
_analytics.logEvent(name: 'button_click', parameters: {'button_id': 'submit'});
_facebookEvents.logCustomEvent(
  eventName: 'button_click',
  parameters: {'button_id': 'submit'},
);
_adjustService.trackEvent('abc123', callbackParameters: {'button_id': 'submit'});

// After
_analytics.logEvent(
  name: 'button_click',
  parameters: {'button_id': 'submit'},
  adjustEventToken: AdjustEvents.someEvent, // Use constant from adjust_config.dart
);
```

##### Screen Views

```dart
// Before
_analytics.logScreenView(screenName: 'Home Screen');
_facebookEvents.logViewContent(
  contentType: 'screen',
  contentId: 'Home Screen',
);

// After
_analytics.logScreenView(screenName: 'Home Screen');
```

##### User Registration

```dart
// Before
_analytics.logSignUp(signUpMethod: 'email');
_facebookEvents.logCompleteRegistration(registrationMethod: 'email');

// After
_analytics.logSignUp(
  signUpMethod: 'email',
);
```

##### Login Events

```dart
// Before
_analytics.logLogin(loginMethod: 'email');
_facebookEvents.logCustomEvent(
  eventName: 'Login',
  parameters: {'method': 'email'},
);

// After
_analytics.logLogin(
  loginMethod: 'email',
);
```

##### Purchases

```dart
// Before
_analytics.logPurchase(
  value: 9.99,
  currency: 'USD',
  items: [AnalyticsEventItem(itemId: 'product_123', price: 9.99)],
);
_facebookEvents.logPurchase(
  price: 9.99,
  currency: 'USD',
  productId: 'product_123',
);
_adjustService.trackRevenue('abc123', 9.99, 'USD');

// After
_analytics.logPurchase(
  price: 9.99,
  currency: 'USD',
  productId: 'product_123',
);
```

##### Purchases with Price String

```dart
// Before
_facebookEvents.logPurchaseWithPriceString(
  priceString: price,
  productIdentifier: packageId,
  parameters: {'question_count': questionCount.toString()},
);

// After
_analytics.logPurchaseWithPriceString(
  priceString: price,
  productIdentifier: packageId,
  parameters: {'question_count': questionCount.toString()},
);
```

##### Subscriptions

```dart
// Before
_analytics.logEvent(
  name: 'subscription_purchase',
  parameters: {
    'subscription_id': 'sub_monthly',
    'price': 4.99,
    'currency': 'USD',
  },
);
_facebookEvents.logSubscribe(
  subscriptionId: 'sub_monthly',
  price: 4.99,
  currency: 'USD',
);
_adjustService.trackRevenue('abc123', 4.99, 'USD');

// After
_analytics.logSubscription(
  subscriptionId: 'sub_monthly',
  price: 4.99,
  currency: 'USD',
);
```

##### Subscription with Price String (for IAP)

```dart
// Before
_analytics.logEvent(
  name: 'subscription_purchase',
  parameters: {
    'subscription_id': 'sub_monthly',
    'price_string': '$4.99',
  },
);
_facebookEvents.logSubscribeWithPriceString(
  subscriptionId: 'sub_monthly',
  priceString: '$4.99',
);

// After
_analytics.logSubscriptionWithPriceString(
  subscriptionId: 'sub_monthly',
  priceString: '$4.99',
);
```

##### Tutorial Completion

```dart
// Before
_analytics.logEvent(name: 'tutorial_complete', parameters: {'method': 'normal'});
_facebookEvents.logCustomEvent(
  eventName: 'tutorial_complete',
  parameters: {'method': 'normal'},
);

// After
_analytics.logEvent(
  name: 'tutorial_complete',
  parameters: {'method': 'normal'},
);
```

#### Step 4: Initialize in main.dart

```dart
// Before
await getIt<AnalyticsService>().initialize();
await getIt<AdjustService>().initialize();
await getIt<FacebookAppEventsService>().logActivateApp();

// After
await getIt<UnifiedAnalyticsService>().initialize();
```

### Implementation Details

The UnifiedAnalyticsService is registered in the DI container and internally uses all three services:

```dart
getIt.registerLazySingleton<UnifiedAnalyticsService>(() => UnifiedAnalyticsService(
  getIt<AnalyticsService>(),
  getIt<FacebookAppEventsService>(),
  getIt<AdjustService>(),
));
```

### Adding New Event Types

If you need to track a new type of event that isn't covered by the existing methods in UnifiedAnalyticsService, consider adding a new method to the service rather than using the individual services directly.

### Error Handling

The UnifiedAnalyticsService includes error handling for each analytics call, ensuring that an error in one analytics service won't affect the others or crash your app.

### Feature Flags and Environment-Specific Configuration

The service respects the individual service configurations for feature flags and environment settings. For example, if analytics collection is disabled in Firebase, the UnifiedAnalyticsService will respect that setting when sending events to Firebase. 