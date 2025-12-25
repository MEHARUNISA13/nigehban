# Nigehbaan App - Setup Instructions

## Prerequisites
- Flutter SDK (3.9.2 or higher)
- Firebase account
- Google Cloud Console account (for Maps API)
- Android Studio or VS Code
- Physical Android device for testing

## Step 1: Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "Nigehbaan"
3. Add an Android app:
   - Package name: `com.example.nigehban`
   - Download `google-services.json` and place it in `android/app/`
4. Add an iOS app (optional):
   - Bundle ID: `com.example.nigehban`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

5. Enable Firebase services:
   - **Authentication**: Enable Email/Password
   - **Firestore Database**: Create database in production mode
   - **Cloud Storage**: Enable for image uploads
   - **Cloud Messaging**: Enable for push notifications

6. Run FlutterFire CLI:
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

## Step 2: Google Maps API Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing Firebase project
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Geocoding API

4. Create API credentials:
   - Create an API key
   - Restrict it to your app (optional but recommended)

5. Add API key to Android:
   - Open `android/app/src/main/AndroidManifest.xml`
   - Add inside `<application>` tag:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>
   ```

6. Add API key to iOS:
   - Open `ios/Runner/AppDelegate.swift`
   - Add `GMSServices.provideAPIKey("YOUR_API_KEY_HERE")`

7. Update `lib/services/places_service.dart`:
   - Replace `YOUR_GOOGLE_PLACES_API_KEY` with your actual API key

## Step 3: Install Dependencies

```bash
cd c:\Users\DELL\Desktop\nigehban
flutter pub get
```

## Step 4: Generate Hive Adapters

```bash
flutter packages pub run build_runner build
```

## Step 5: Update Android Permissions

The `AndroidManifest.xml` needs these permissions (add if missing):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.SEND_SMS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```

## Step 6: Run the App

1. Connect your Android device
2. Enable USB debugging
3. Run:
```bash
flutter run
```

## Step 7: Testing Checklist

- [ ] App launches and shows splash screen
- [ ] Onboarding screens display correctly
- [ ] Sign up with email/password works
- [ ] Login works
- [ ] Home screen displays
- [ ] Location permission is requested
- [ ] Map screen loads
- [ ] Can add emergency contacts
- [ ] SOS button works (test carefully!)
- [ ] Can create a report with image
- [ ] Reports list displays
- [ ] Settings screen works

## Troubleshooting

### Firebase not initializing
- Make sure `google-services.json` is in `android/app/`
- Run `flutterfire configure` again
- Check Firebase console for correct package name

### Maps not showing
- Verify API key is correct
- Check that Maps SDK is enabled in Google Cloud Console
- Ensure billing is enabled (required for Maps API)

### Location not working
- Test on real device (emulator location is unreliable)
- Check location permissions in device settings
- Ensure GPS is enabled

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- Delete `build` folder and rebuild

## Next Steps

1. Add your own app icon using `flutter_launcher_icons`
2. Configure app signing for release
3. Test thoroughly on multiple devices
4. Prepare screenshots for app store
5. Submit to Huawei AppGallery or Google Play Store

## Important Notes

- **Never commit API keys to version control**
- Test SOS feature carefully (it sends real SMS)
- Ensure you have test contacts before activating SOS
- Firebase free tier has limits - monitor usage
- Google Maps API has free tier but requires billing account
