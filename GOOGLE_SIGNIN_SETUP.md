# Google Sign-In Setup Instructions

## Overview
This project includes Google Sign-In integration with Supabase. To fully configure Google Sign-In, you need to:

## 1. Supabase Configuration
1. Go to your Supabase project dashboard
2. Navigate to Authentication > Providers
3. Enable Google provider
4. Add your Google OAuth credentials:
   - Client ID (from Google Cloud Console)
   - Client Secret (from Google Cloud Console)

## 2. Google Cloud Console Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable Google+ API
4. Go to Credentials > Create Credentials > OAuth 2.0 Client IDs
5. Create credentials for:
   - **Android application**
   - **Web application** (for Supabase)

### Android Configuration
1. Get your Android SHA-1 certificate fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Add the SHA-1 fingerprint to your Google Cloud Console OAuth client
3. Package name: `com.ghulmil.application`

### Web Configuration (for Supabase)
1. In Google Cloud Console, create a Web application OAuth client
2. Add your Supabase project URL to authorized redirect URIs:
   ```
   https://your-project-ref.supabase.co/auth/v1/callback
   ```

## 3. Update AuthService Configuration
In `lib/src/services/auth_service.dart`, update the client IDs:

```dart
const webClientId = 'YOUR_WEB_CLIENT_ID_HERE';
const iosClientId = 'YOUR_IOS_CLIENT_ID_HERE'; // Optional for iOS
```

## 4. Android Configuration File
Create `android/app/google-services.json` from your Firebase/Google Cloud project.

## Current Status
- ✅ Google Sign-In package added
- ✅ UI components implemented
- ✅ AuthService updated
- ✅ AuthProvider updated
- ⏳ Needs Google Cloud Console configuration
- ⏳ Needs Supabase provider configuration
- ⏳ Needs client ID configuration

## Testing
Once configured, users can:
- Sign in with Google from the sign-in screen
- Register with Google from the sign-up screen
- Automatically create user profiles in Supabase
