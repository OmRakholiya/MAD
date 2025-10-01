# 🔥 Complete Firebase Setup Guide for Flutter Fitness Tracker

## Step 1: Create Firebase Project

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Click "Create a project"**
3. **Enter project name**: `flutter-fitness-tracker` (or your preferred name)
4. **Enable Google Analytics**: Choose "Yes" (recommended)
5. **Select Analytics account** or create new one
6. **Click "Create project"**
7. **Wait for project creation** (1-2 minutes)

## Step 2: Add Web App to Firebase

1. **In your Firebase project dashboard**:
   - Click **"Add app"** → Select **Web** icon (</>)
   - **App nickname**: `Flutter Fitness Tracker Web`
   - **Check "Also set up Firebase Hosting"** (optional)
   - Click **"Register app"**

2. **Copy the Firebase configuration**:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
     authDomain: "your-project-id.firebaseapp.com",
     projectId: "your-project-id",
     storageBucket: "your-project-id.appspot.com",
     messagingSenderId: "123456789012",
     appId: "1:123456789012:web:abcdef1234567890abcdef"
   };
   ```

3. **Click "Continue to console"**

## Step 3: Add Android App to Firebase

1. **Click "Add app"** → Select **Android** icon (🤖)
2. **Android package name**: `com.example.flutter_fitness_tracker`
3. **App nickname**: `Flutter Fitness Tracker`
4. **Debug signing certificate SHA-1**: Leave empty
5. **Click "Register app"**
6. **Download `google-services.json`**
7. **Replace** `android/app/google-services.json` with downloaded file
8. **Click "Continue to console"**

## Step 4: Add iOS App to Firebase (Optional)

1. **Click "Add app"** → Select **iOS** icon (🍎)
2. **iOS bundle ID**: `com.example.flutterFitnessTracker`
3. **App nickname**: `Flutter Fitness Tracker iOS`
4. **App Store ID**: Leave empty
5. **Click "Register app"**
6. **Download `GoogleService-Info.plist`**
7. **Replace** `ios/Runner/GoogleService-Info.plist` with downloaded file
8. **Click "Continue to console"**

## Step 5: Enable Authentication

1. **Go to "Authentication"** in left sidebar
2. **Click "Get started"**
3. **Go to "Sign-in method" tab**
4. **Click "Email/Password"**
5. **Toggle "Enable" to ON**
6. **Click "Save"**

## Step 6: Create Firestore Database

1. **Go to "Firestore Database"** in left sidebar
2. **Click "Create database"**
3. **Select "Start in test mode"** (for development)
4. **Click "Next"**
5. **Choose location** (closest to your users)
6. **Click "Done"**

## Step 7: Configure Security Rules

1. **In Firestore Database** → **"Rules" tab**
2. **Replace existing rules with**:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users can read/write their own user document
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Users can read/write their own workouts
       match /workouts/{workoutId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
         allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
       }
       
       // Users can read/write their own progress
       match /progress/{progressId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
         allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
       }
     }
   }
   ```
3. **Click "Publish"**

## Step 8: Update Firebase Configuration in Code

1. **Open `lib/firebase_options.dart`**
2. **Replace the placeholder values** with your actual Firebase config:

   **For Web:**
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'YOUR_ACTUAL_API_KEY',
     appId: 'YOUR_ACTUAL_APP_ID',
     messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
     projectId: 'YOUR_ACTUAL_PROJECT_ID',
     authDomain: 'YOUR_ACTUAL_PROJECT_ID.firebaseapp.com',
     storageBucket: 'YOUR_ACTUAL_PROJECT_ID.appspot.com',
   );
   ```

   **For Android:**
   ```dart
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'YOUR_ACTUAL_API_KEY',
     appId: 'YOUR_ACTUAL_APP_ID',
     messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
     projectId: 'YOUR_ACTUAL_PROJECT_ID',
     storageBucket: 'YOUR_ACTUAL_PROJECT_ID.appspot.com',
   );
   ```

   **For iOS:**
   ```dart
   static const FirebaseOptions ios = FirebaseOptions(
     apiKey: 'YOUR_ACTUAL_API_KEY',
     appId: 'YOUR_ACTUAL_APP_ID',
     messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
     projectId: 'YOUR_ACTUAL_PROJECT_ID',
     storageBucket: 'YOUR_ACTUAL_PROJECT_ID.appspot.com',
     iosBundleId: 'com.example.flutterFitnessTracker',
   );
   ```

## Step 9: Test Your App

1. **Run the app**: `flutter run`
2. **Test registration**: Create a new account
3. **Test login**: Sign in with your credentials
4. **Test logout**: Use logout button in Profile tab
5. **Test password reset**: Use "Forgot Password" on login screen

## Step 10: Switch to Firebase Auth (Optional)

Once Firebase is working, you can switch from SimpleAuthService to FirebaseAuthService:

1. **Update imports** in your screens:
   ```dart
   import '../services/firebase_auth_service.dart';
   ```

2. **Replace SimpleAuthService calls** with FirebaseAuthService calls

## Troubleshooting

### Common Issues:

1. **Blank page**: Make sure Firebase configuration is correct
2. **Authentication errors**: Check if Email/Password is enabled in Firebase Console
3. **Database errors**: Verify Firestore rules and database creation
4. **Build errors**: Ensure all configuration files are in correct locations

### Getting Your Firebase Config Values:

- **API Key**: Found in Firebase Console → Project Settings → General
- **Project ID**: Found in Firebase Console → Project Settings → General
- **App ID**: Found in Firebase Console → Project Settings → General
- **Auth Domain**: Usually `your-project-id.firebaseapp.com`
- **Storage Bucket**: Usually `your-project-id.appspot.com`
- **Sender ID**: Found in Firebase Console → Project Settings → Cloud Messaging

## Next Steps

After Firebase is set up:
1. Add workout tracking functionality
2. Implement progress charts
3. Add social features
4. Deploy to production
5. Add push notifications
