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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAp7onUs0BqUQISJ29665sWfcMSwKH00wk',
    appId: '1:686367810156:android:acc2e1e92e8a21bf0fee49',
    messagingSenderId: '686367810156',
    projectId: 'aidoc-9337e',
    authDomain: 'aidoc-9337e.firebaseapp.com',
    storageBucket: 'aidoc-9337e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAp7onUs0BqUQISJ29665sWfcMSwKH00wk',
    appId: '1:686367810156:android:acc2e1e92e8a21bf0fee49',
    messagingSenderId: '686367810156',
    projectId: 'aidoc-9337e',
    storageBucket: 'aidoc-9337e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAp7onUs0BqUQISJ29665sWfcMSwKH00wk',
    appId: '1:686367810156:android:acc2e1e92e8a21bf0fee49',
    messagingSenderId: '686367810156',
    projectId: 'aidoc-9337e',
    storageBucket: 'aidoc-9337e.firebasestorage.app',
    iosClientId: 'YOUR-IOS-CLIENT-ID',
    iosBundleId: 'YOUR-IOS-BUNDLE-ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAp7onUs0BqUQISJ29665sWfcMSwKH00wk',
    appId: '1:686367810156:android:acc2e1e92e8a21bf0fee49',
    messagingSenderId: '686367810156',
    projectId: 'aidoc-9337e',
    storageBucket: 'aidoc-9337e.firebasestorage.app',
    iosClientId: 'YOUR-MACOS-CLIENT-ID',
    iosBundleId: 'YOUR-MACOS-BUNDLE-ID',
  );
} 