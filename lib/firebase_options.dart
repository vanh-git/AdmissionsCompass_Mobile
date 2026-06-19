import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBLbkyC5-v_aGrTB1vFkfXpV3kReCZvg8k',
    authDomain: 'exe-labantuyensinh.firebaseapp.com',
    projectId: 'exe-labantuyensinh',
    storageBucket: 'exe-labantuyensinh.firebasestorage.app',
    messagingSenderId: '318816534338',
    appId: '1:318816534338:web:54c6343f0279446bac12db',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLbkyC5-v_aGrTB1vFkfXpV3kReCZvg8k',
    appId: '1:318816534338:android:PLACEHOLDER',
    messagingSenderId: '318816534338',
    projectId: 'exe-labantuyensinh',
    storageBucket: 'exe-labantuyensinh.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBLbkyC5-v_aGrTB1vFkfXpV3kReCZvg8k',
    appId: '1:318816534338:ios:PLACEHOLDER',
    messagingSenderId: '318816534338',
    projectId: 'exe-labantuyensinh',
    storageBucket: 'exe-labantuyensinh.firebasestorage.app',
    iosBundleId: 'com.example.admissionscompass',
  );
}
