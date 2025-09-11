// File generated manually for Firebase configuration
// Replace these values with your actual Firebase project configuration

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMWOBzXQOa1G1rCW5sZITUr-Z4uHXQcU4',
    appId: '1:87062363095:android:a311d8cbedca26789ce992',
    messagingSenderId: '87062363095',
    projectId: 'bookmyspot-c8bdb',
    databaseURL: 'https://bookmyspot-c8bdb.firebaseio.com',
    storageBucket: 'bookmyspot-c8bdb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCKHDQXgXVQpsyNhEEAN-OMsc2xPoLeim4',
    appId: '1:87062363095:ios:febbb7d78ae2995e9ce992',
    messagingSenderId: '87062363095',
    projectId: 'bookmyspot-c8bdb',
    databaseURL: 'https://bookmyspot-c8bdb.firebaseio.com',
    storageBucket: 'bookmyspot-c8bdb.firebasestorage.app',
    androidClientId: '87062363095-0t7f8es54hej621g3lukhfv12s2brdsf.apps.googleusercontent.com',
    iosClientId: '87062363095-0pjkbi3fpige02omr3mqlbpbq920uiao.apps.googleusercontent.com',
    iosBundleId: 'com.zyphram.InterviewAce',
  );

}