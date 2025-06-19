# Flutter Review App

A comprehensive Flutter application for sharing and viewing airline reviews with authentication, media upload, and social interactions.

## Features

- **Email/Password Authentication** using Firebase Auth
- **Share Reviews** with multiple images/videos, ratings, and detailed information
- **View Feed** with reviews from all users
- **Like & Comment** on reviews (authenticated users only)
- **Share Reviews** via native sharing
- **Cloudinary Integration** for media upload with progress tracking
- **Responsive Design** with clean UI/UX

## Setup Instructions

### 1. Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  cloudinary_public: ^0.21.0
  image_picker: ^1.0.4
  file_picker: ^6.1.1
  video_player: ^2.8.1
  flutter_rating_bar: ^4.0.1
  dropdown_search: ^5.0.6
  intl: ^0.18.1
  share_plus: ^7.2.1
  flutter_riverpod: ^2.4.9
  uuid: ^4.2.1
  cached_network_image: ^3.3.0
```

### 2. Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Email/Password Authentication** in Firebase Auth
3. Update the Firebase configuration in `lib/core/configs/firebase.dart`
4. Add your platform-specific Firebase configuration files:
    - Android: `android/app/google-services.json`
    - iOS: `ios/Runner/GoogleService-Info.plist`

### 3. Cloudinary Configuration

Update the Cloudinary credentials in `lib/core/configs/cloudinary.dart`:

```dart
class CloudinaryConfig {
  static const String cloudName = 'dbidxhnrs';
  static const String apiKey = '158735958714288';
  static const String apiSecret = 'x5C8sc_jsrxelH5aRlSjEN5_rh8';
  static const String uploadPreset = 'bolt_unsigned';
}
```

### 4. Firestore Security Rules

Deploy the following security rules to your Firestore database:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    
    match /users/{userId} {
      allow create: if isSignedIn() && request.auth.uid == userId;
      allow read: if true;
      allow update: if isSignedIn() && request.auth.uid == userId;
    }
    
    match /reviews/{reviewId} {
      allow create: if isSignedIn()
        && request.resource.data.authorId == request.auth.uid
        && request.resource.data.authorName is string
        && request.resource.data.departure is string
        && request.resource.data.arrival is string
        && request.resource.data.airline is string
        && request.resource.data.travelClass is string
        && request.resource.data.description is string
        && request.resource.data.rating is number
        && request.resource.data.mediaUrls is list
        && request.resource.data.mediaTypes is list
        && request.resource.data.createdAt == request.time;
      allow read: if true;
      allow update, delete: if request.auth.uid == resource.data.authorId;
    }
    
    match /reviews/{reviewId}/likes/{likeId} {
      allow create, delete: if isSignedIn() && request.auth.uid == likeId;
      allow read: if true;
    }
    
    match /reviews/{reviewId}/comments/{commentId} {
      allow create: if isSignedIn()
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.userName is string
        && request.resource.data.text is string
        && request.resource.data.createdAt == request.time;
      allow read: if true;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### 5. Android Permissions

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

## Architecture

The app follows **Clean Architecture** principles with feature-first organization:

- **Core**: Shared configurations, constants, utilities, and widgets
- **Features**: Organized by functionality (auth, share_review, review_feed)
- **Presentation**: UI components and ViewModels
- **Domain**: Business logic and entities
- **Data**: Services and repositories

## Usage

1. **Authentication**: Users can sign up/login with email and password
2. **Viewing Feed**: All users (authenticated and unauthenticated) can view the review feed
3. **Sharing Reviews**: Only authenticated users can share reviews with:
    - Multiple images or one video
    - Departure/arrival airports
    - Airline and travel class
    - Description and rating
    - Travel date
4. **Interactions**: Authenticated users can:
    - Like/unlike reviews
    - Comment on reviews
    - Share reviews via native sharing

## Data Structure

### Reviews Collection
```
{
  authorId: string,
  authorName: string,
  departure: string,
  arrival: string,
  airline: string,
  travelClass: string,
  description: string,
  travelDate: timestamp,
  rating: number,
  mediaUrls: array,
  mediaTypes: array,
  createdAt: timestamp,
  likesCount: number,
  commentsCount: number
}
```

### Likes Subcollection
```
reviews/{reviewId}/likes/{userId}: { userId: string }
```

### Comments Subcollection
```
reviews/{reviewId}/comments/{commentId}: {
  userId: string,
  userName: string,
  text: string,
  createdAt: timestamp
}
```

## Testing Firebase Rules

Use the Firebase Console Rules Simulator to test:

1. Unauthenticated users can read reviews but cannot create/update
2. Authenticated users can only create reviews with their own `authorId`
3. Users can only like/unlike with their own `userId`
4. Comments must include valid `userId`, `userName`, and `text`

## Features Overview

- **Clean Architecture**: Feature-first organization with proper separation of concerns
- **State Management**: Riverpod for reactive state management
- **Authentication**: Firebase Email/Password with user profiles
- **Media Upload**: Cloudinary integration with progress tracking
- **Real-time Updates**: Firestore streams for live feed updates
- **Responsive UI**: Material Design 3 with custom styling
- **Security**: Comprehensive Firestore security rules
- **Offline Support**: Cached network images for better performance