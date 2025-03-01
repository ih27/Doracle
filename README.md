# Doracle - Your Personal Pet Oracle 🐾

A sophisticated Flutter application that combines pet lifestyle management with AI-powered insights and compatibility analysis.

## Features 🌟

### Core Features
- **Pet & Owner Profiles**: Comprehensive profile management with detailed characteristics
- **AI Oracle**: Get personalized insights about your pet relationship
- **Compatibility Analysis**: Deep analysis of pet-owner and pet-pet compatibility
- **Daily Horoscopes**: Personalized astrological insights
- **Fortune Telling**: AI-powered responses to your questions

### Technical Features
- **Authentication**: Email/Password, Google Sign-in, Apple Sign-in
- **Cloud Integration**: Firebase (Auth, Firestore, Analytics, Crashlytics)
- **AI Integration**: OpenAI API for intelligent responses
- **Monetization**: RevenueCat for subscriptions and in-app purchases
- **Animations**: Custom Rive animations and interactive elements

## Getting Started 🚀

### Prerequisites
- Flutter SDK >=3.4.3
- Dart SDK >=3.4.3
- Firebase project setup
- OpenAI API key
- RevenueCat account

### Environment Setup
1. Clone the repository
2. Create a `.env` file in the root directory with:
   ```
   OPENAI_API_KEY=your_api_key
   FIREBASE_ANDROID_API_KEY=your_firebase_android_key
   FIREBASE_IOS_API_KEY=your_firebase_ios_key
   ```
3. Run `flutter pub get`
4. Configure Firebase using the provided options in `lib/config/firebase_options.dart`

## Architecture 🏗️

The app follows a clean architecture pattern with:
- **Entities**: Core business objects (Pet, Owner)
- **Services**: Business logic and external integrations
- **Repositories**: Data access layer
- **Providers**: State management
- **UI**: Screens and widgets

## Dependencies 📦

Key packages:
- `firebase_core`, `firebase_auth`, etc.: Firebase integration
- `dart_openai`: OpenAI API integration
- `purchases_flutter`: RevenueCat integration
- `provider`: State management
- `rive`: Custom animations
- `get_it`: Dependency injection

## Best Practices 💡

1. Use `SizedBox` for whitespace instead of `Container`
2. Utilize `const` constructors where possible
3. Include named `key` parameter for public widgets
4. Follow Flutter performance guidelines
5. Implement proper error handling
6. Use dependency injection for better testability

## Future Improvements 🔮

1. **Testing**: Add comprehensive unit and widget tests
2. **Localization**: Support multiple languages
3. **Offline Support**: Implement local data persistence
4. **Performance Optimization**: Cache optimization and lazy loading
5. **UI/UX Enhancements**: More interactive animations
6. **Analytics**: Enhanced user behavior tracking
7. **Social Features**: Pet community and sharing capabilities

## Security 🔒

- Firebase App Check implementation
- Secure API key management
- User data encryption
- Privacy-focused design

## Contributing 🤝

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License 📄

This project is proprietary software. All rights reserved.