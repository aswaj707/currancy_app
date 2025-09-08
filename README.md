# 💱 Currency Converter App

A beautiful and feature-rich Flutter app for real-time currency conversion with live exchange rates, historical charts, and favorites management.

## ✨ Features

### 🔄 Currency Conversion
- **Real-time Exchange Rates**: Fetch live exchange rates from the Frankfurter API
- **Multi-Currency Support**: Support for 25+ major currencies including USD, EUR, GBP, JPY, INR, and more
- **Instant Conversion**: Convert amounts instantly as you type
- **Currency Swapping**: Quick swap between source and target currencies

### 📊 Rate History
- **7-Day Historical Data**: View exchange rate trends over the past week
- **Interactive Charts**: Beautiful line charts using fl_chart package
- **Rate Statistics**: Display highest, lowest, and average rates
- **Visual Analytics**: Gradient-filled charts with smooth curves

### 🏦 Favorites Management
- **Bookmark Currency Pairs**: Save frequently used currency combinations
- **Quick Access**: Instantly access your favorite conversions
- **Persistent Storage**: Favorites saved locally using SharedPreferences
- **Bulk Management**: Clear all favorites with confirmation dialog

### 🎨 Modern UI/UX
- **Material Design 3**: Clean, modern interface following Material Design guidelines
- **Flag Icons**: Country flags for visual currency identification
- **Card-based Layout**: Organized content in beautiful cards
- **Responsive Design**: Optimized for different screen sizes
- **Loading States**: Smooth loading indicators and error handling
- **Bottom Navigation**: Easy switching between Converter, History, and Favorites

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.6.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_currancy_api
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Converter Screen
- Input amount with real-time conversion
- Currency selection dropdowns with flags
- Exchange rate display
- Favorite toggle functionality

### History Screen
- Interactive 7-day rate chart
- Rate statistics (highest, lowest, average)
- Currency pair selection
- Refresh functionality

### Favorites Screen
- List of saved currency pairs
- Real-time rate display for favorites
- Remove individual or clear all favorites
- Empty state with helpful guidance

## 🛠️ Technical Implementation

### Architecture
- **Clean Architecture**: Separated models, services, and UI components
- **State Management**: Local state management with setState
- **API Integration**: RESTful API calls using http package
- **Local Storage**: SharedPreferences for favorites persistence

### Key Packages
- `http`: API calls to Frankfurter API
- `fl_chart`: Beautiful charts for rate history
- `shared_preferences`: Local storage for favorites
- `intl`: Date formatting and localization
- `provider`: State management (ready for future enhancement)

### API Integration
- **Frankfurter API**: Free, reliable exchange rate API
- **Real-time Rates**: Current exchange rates
- **Historical Data**: 7-day rate history
- **Error Handling**: Comprehensive error handling and retry mechanisms

## 📁 Project Structure

```
lib/
├── data/
│   └── currencies.dart          # Currency data with flags and symbols
├── models/
│   ├── currency.dart            # Currency model
│   ├── exchange_rate.dart       # Exchange rate model
│   └── rate_history.dart        # Rate history model
├── screens/
│   ├── converter_screen.dart    # Main conversion screen
│   ├── history_screen.dart      # Rate history with charts
│   └── favorites_screen.dart    # Favorites management
├── services/
│   ├── api_service.dart         # API integration
│   └── favorites_service.dart   # Favorites storage
├── widgets/
│   ├── currency_dropdown.dart   # Currency selection widget
│   ├── currency_card.dart       # Currency display card
│   └── loading_widget.dart      # Loading and error widgets
└── main.dart                    # App entry point
```

## 🎯 Features in Detail

### Currency Conversion
- Input validation for numeric amounts
- Real-time rate fetching and conversion
- Support for decimal amounts
- Currency symbol display
- Rate information display

### Rate History
- 7-day historical data visualization
- Interactive line charts with gradients
- Statistical analysis (min, max, average)
- Date formatting and display
- Smooth animations and transitions

### Favorites System
- Add/remove currency pairs
- Persistent local storage
- Bulk operations (clear all)
- Real-time rate updates for favorites
- User-friendly confirmation dialogs

## 🔧 Customization

### Adding New Currencies
Edit `lib/data/currencies.dart` to add new currencies:
```dart
Currency(
  code: 'NEW',
  name: 'New Currency',
  flag: '🏳️',
  symbol: 'N',
),
```

### API Configuration
Modify `lib/services/api_service.dart` to use different APIs or endpoints.

### UI Theming
Customize colors and styling in `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue, // Change primary color
  brightness: Brightness.light,
),
```

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

The app includes widget tests to ensure UI components render correctly.

## 📦 Build & Deploy

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Frankfurter API](https://api.frankfurter.app/) for providing free exchange rate data
- [Flutter](https://flutter.dev/) for the amazing framework
- [fl_chart](https://pub.dev/packages/fl_chart) for beautiful charts
- Material Design for UI guidelines

## 📞 Support

If you encounter any issues or have questions, please open an issue on GitHub.

---

**Happy Converting! 💱✨**
