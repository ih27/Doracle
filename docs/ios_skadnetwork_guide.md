# iOS SkAdNetwork Integration Guide for Doracle

This guide explains the iOS SkAdNetwork implementation in Doracle, focusing on Facebook App Events integration.

## What is SkAdNetwork?

SkAdNetwork is Apple's privacy-friendly attribution framework that allows advertisers to measure the success of their ad campaigns without tracking individual users. It was introduced with iOS 14 and became more important with the release of iOS 14.5, which requires apps to ask for permission before tracking users via the App Tracking Transparency (ATT) framework.

## Implementation in Doracle

### 1. SkAdNetwork IDs in Info.plist

We've added Facebook's SkAdNetwork IDs to the Info.plist file. These IDs allow Facebook to receive install attribution data from Apple, even when users opt out of tracking.

```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v9wttpbfk9.skadnetwork</string>
    </dict>
    <!-- Additional SkAdNetwork IDs -->
    ...
</array>
```

### 2. Enhanced Event Logging

The `FacebookAppEventsService` has been enhanced to support SkAdNetwork attribution. Key modifications include:

- Adding `schema: 'SKAdNetwork'` parameter to event logging
- Adding specific conversion value updates for important events
- Supporting iOS 14+ specific event logging

### 3. Conversion Values

Conversion values (0-63) are used to indicate user value to advertisers. In Doracle, we use:

| User Action | Conversion Value | Explanation |
|-------------|-----------------|-------------|
| App Install | 1 | Initial app install |
| Registration | 2 | User completed registration |
| Purchase | 4 | User made a one-time purchase |
| Subscription | 6 | User subscribed (highest value) |

### 4. App Tracking Transparency

Doracle already implements ATT through the `permission_handler` package, asking users for permission to track them with the message:

```
We use your data to provide personalized fortune readings and improve our mystical services. This helps us offer a better experience tailored to your spiritual journey.
```

## Testing SkAdNetwork Integration

To test the SkAdNetwork integration:

1. **Basic Testing**:
   - Run your app on an iOS 14+ device
   - Check console logs for "Facebook App Events initialized with SKAdNetwork support"
   - Verify conversion value updates in logs

2. **Facebook Events Manager**:
   - Go to Facebook Events Manager at [business.facebook.com/events_manager](https://business.facebook.com/events_manager)
   - Choose the "Configure" option in Events Manager
   - Select "Import from partner app" for the automatic SkAdNetwork configuration
   - Follow the prompts to complete the setup

3. **Install Validation**:
   - Create a test Facebook ad campaign targeting iOS 14+ devices
   - Use a test device to install your app through the ad
   - Check Events Manager for installs attributed via SkAdNetwork

## Troubleshooting

- **No events in Facebook Analytics**: It can take up to 24-48 hours for events to appear
- **Conversion values not updating**: Ensure the app has proper network connectivity
- **Missing attribution data**: Verify all required SkAdNetwork IDs are in Info.plist
- **Low opt-in rate**: Consider improving your App Tracking Transparency prompt messaging

## Best Practices

1. **Multiple Event Logging**: Log important events both with and without the SkAdNetwork schema
2. **Conversion Value Strategy**: Define a clear strategy for conversion values based on your business goals
3. **Test with Real Devices**: Always test on physical iOS 14+ devices, not just simulators
4. **Regular Updates**: Keep Facebook SDK and SkAdNetwork IDs up to date

## Resources

- [Facebook SKAdNetwork Documentation](https://developers.facebook.com/docs/SKAdNetwork)
- [Apple SKAdNetwork Documentation](https://developer.apple.com/documentation/storekit/skadnetwork)
- [App Tracking Transparency Guide](https://developer.apple.com/documentation/apptrackingtransparency) 