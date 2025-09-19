# AtlasIQ Mobile

A SwiftUI-based iOS application for AtlasIQ.

## 🚀 Project Status

- **Platform**: iOS
- **Framework**: SwiftUI
- **Language**: Swift
- **Minimum iOS Version**: iOS 17.0+
- **Bundle ID**: `eric.AtlasIQ-Mobile`
- **Version**: 1.0 (Build 1)

## 📱 Features

- **Authentication System**: Sign in with Apple integration
- **Firebase Integration**: Secure user management and data storage
- **Modern SwiftUI Interface**: Clean, responsive design with liquid glass aesthetics
- **Professional OSINT Platform**: Intelligence analysis tools
- **Security-First Design**: Privacy-focused authentication and data handling

## 🛠 Development Setup

### Prerequisites
- Xcode 16.4+
- iOS 17.0+ Simulator or Device
- Apple Developer Account (for device testing)

### Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/geosoldier/atlasiq-mobile.git
   cd atlasiq-mobile
   ```

2. **Configure Firebase** (Required for authentication):
   - Create a Firebase project at https://console.firebase.google.com/
   - Add iOS app with Bundle ID: `eric.AtlasIQ-Mobile`
   - Download `GoogleService-Info.plist` and add to Xcode project
   - Enable Sign in with Apple in Firebase Authentication
   - Configure Apple Developer credentials (Team ID, Key ID, Private Key)

3. **Configure Apple Sign in**:
   - Enable "Sign in with Apple" capability in Xcode
   - Set Apple Developer Team ID in project settings
   - Ensure proper entitlements are configured

4. Open the project in Xcode:
   ```bash
   open "AtlasIQ Mobile.xcodeproj"
   ```

5. Build and run the project (`Cmd+R`)

## 🔄 CI/CD Pipeline

This project is configured with **Xcode Cloud** for continuous integration and deployment:

### Workflows
- **CI Workflow**: Runs on every commit to `main` branch
  - Builds the project
  - Runs unit tests
  - Runs UI tests
  - Validates code quality

- **Nightly Workflow**: Runs nightly builds for stability testing

- **Release Workflow**: Runs when creating releases
  - Builds release version
  - Archives for App Store submission
  - Runs comprehensive test suite

### Workflow Status
- ✅ GitHub Integration: Connected
- ✅ Xcode Cloud: Configured
- ✅ CI/CD Pipeline: Active

## 📁 Project Structure

```
AtlasIQ Mobile/
├── AtlasIQ Mobile/                    # Main app source code
│   ├── AtlasIQ_MobileApp.swift       # App entry point with Firebase initialization
│   ├── ContentView.swift             # Root view with authentication flow
│   ├── LoginView.swift               # Sign in with Apple authentication
│   ├── MainPageView.swift            # Main navigation with 3 OSINT options
│   ├── SocialMediaIntelligenceView.swift    # Social media analysis tools
│   ├── ThreatAssessmentView.swift           # Threat assessment features
│   ├── IntelligenceReportsView.swift        # Report generation
│   ├── GoogleService-Info.plist      # Firebase configuration (local only)
│   ├── AtlasIQ Mobile.entitlements   # Sign in with Apple entitlements
│   └── Assets.xcassets/              # App assets and icons
├── AtlasIQ MobileTests/              # Unit tests
├── AtlasIQ MobileUITests/            # UI tests
└── README.md                         # This file
```

## 🧪 Testing

### Running Tests
- **Unit Tests**: `Cmd+U` in Xcode
- **UI Tests**: Run through Xcode Test Navigator
- **CI Tests**: Automatically run on every commit via Xcode Cloud

### Test Coverage
- Unit tests for business logic
- UI tests for user interactions
- Integration tests for API calls (when implemented)

## 📦 Dependencies

### Apple Frameworks
- **SwiftUI**: Modern UI framework
- **Foundation**: Core functionality
- **AuthenticationServices**: Sign in with Apple
- **CryptoKit**: Cryptographic operations for authentication

### Third-Party Dependencies
- **Firebase Core**: Firebase initialization and configuration
- **Firebase Auth**: User authentication and management

## 🚀 Deployment

### App Store Deployment
1. Ensure all tests pass in Xcode Cloud
2. Create a release tag:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
3. Xcode Cloud will automatically build and prepare for App Store submission

### TestFlight Distribution
- Automatic builds available through Xcode Cloud
- Internal testing enabled for team members
- External testing available for beta users

## 🔧 Configuration

### Bundle Configuration
- **Bundle ID**: `eric.AtlasIQ-Mobile`
- **Display Name**: AtlasIQ Mobile
- **Version**: 1.0
- **Build Number**: 1

### Authentication Configuration
- **Sign in with Apple**: Enabled with proper entitlements
- **Firebase Integration**: Configured with secure API keys
- **Apple Developer Team**: Configured for authentication
- **Privacy Protection**: Apple Private Relay email support

### Signing
- Automatic signing enabled
- Development team configured
- Provisioning profiles managed automatically
- Sign in with Apple capability enabled

## 📝 Development Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain consistent naming conventions

### Git Workflow
- Use feature branches for new features
- Merge to `main` via pull requests
- Keep commits atomic and descriptive
- **Security Note**: Never commit `GoogleService-Info.plist` or API keys

### Testing Requirements
- All new features must include tests
- UI changes require UI tests
- Critical paths must have unit test coverage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software. All rights reserved.

## 📞 Support

For questions or support, please contact the development team.

## 🔒 Security Features

### Authentication Security
- **Sign in with Apple**: Privacy-focused authentication
- **Firebase Security**: Secure user management and data storage
- **API Key Protection**: Configuration files excluded from version control
- **Apple Private Relay**: User email privacy protection
- **Secure Nonce Generation**: Cryptographic security for authentication

### Data Protection
- **No Password Storage**: Apple handles all authentication
- **Encrypted Communication**: All Firebase communications encrypted
- **Privacy-First Design**: Minimal data collection approach

---

**Last Updated**: September 19, 2025  
**Xcode Cloud Status**: ✅ Active  
**Build Status**: ✅ Passing  
**Authentication**: ✅ Sign in with Apple + Firebase









