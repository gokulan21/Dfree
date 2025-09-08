import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAxG-iZSfUmUNSOAE_hReXB_70e3nrSLX8',
    appId: '1:1056911064297:web:8e82f1781a3cf67eb00478',
    messagingSenderId: '1056911064297',
    projectId: 'flutterproject25',
    authDomain: 'flutterproject25.firebaseapp.com',
    storageBucket: 'flutterproject25.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX', // Optional: Add if you're using Analytics
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAxG-iZSfUmUNSOAE_hReXB_70e3nrSLX8',
    appId: '1:1056911064297:android:8e82f1781a3cf67eb00478',
    messagingSenderId: '1056911064297',
    projectId: 'flutterproject25',
    storageBucket: 'flutterproject25.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxKY8YvBkQf9X2_example_ios_key',
    appId: '1:1056911064297:ios:8e82f1781a3cf67eb00478',
    messagingSenderId: '1056911064297',
    projectId: 'flutterproject25',
    storageBucket: 'flutterproject25.firebasestorage.app',
    iosBundleId: 'com.example.freelanceHub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBxKY8YvBkQf9X2_example_macos_key',
    appId: '1:1056911064297:macos:8e82f1781a3cf67eb00478',
    messagingSenderId: '1056911064297',
    projectId: 'flutterproject25',
    storageBucket: 'flutterproject25.firebasestorage.app',
    iosBundleId: 'com.example.freelanceHub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBxKY8YvBkQf9X2_example_windows_key',
    appId: '1:1056911064297:windows:8e82f1781a3cf67eb00478',
    messagingSenderId: '1056911064297',
    projectId: 'flutterproject25',
    authDomain: 'flutterproject25.firebaseapp.com',
    storageBucket: 'flutterproject25.firebasestorage.app',
  );
}
