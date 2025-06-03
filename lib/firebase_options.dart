
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


/// ```
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
    apiKey: 'AIzaSyA7KR1EU5zdG7Kp3gDfT1KHWrp8bi5O2dE',
    appId: '1:202403588023:web:2d6caef9b74d031d0c6a32',
    messagingSenderId: '202403588023',
    projectId: 'panaderia-d6279',
    authDomain: 'panaderia-d6279.firebaseapp.com',
    databaseURL: 'https://panaderia-d6279-default-rtdb.firebaseio.com',
    storageBucket: 'panaderia-d6279.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYn6Hi1MKdYli85FXtnnJa6UpEnMOF3q0',
    appId: '1:202403588023:android:ec5b72eb31b78cad0c6a32',
    messagingSenderId: '202403588023',
    projectId: 'panaderia-d6279',
    databaseURL: 'https://panaderia-d6279-default-rtdb.firebaseio.com',
    storageBucket: 'panaderia-d6279.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjpnp4d1Bv3-xZdBiGgWEnJvkeySg25X4',
    appId: '1:202403588023:ios:3d9ff0336c6bab8f0c6a32',
    messagingSenderId: '202403588023',
    projectId: 'panaderia-d6279',
    databaseURL: 'https://panaderia-d6279-default-rtdb.firebaseio.com',
    storageBucket: 'panaderia-d6279.firebasestorage.app',
    iosBundleId: 'com.example.pancito',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBjpnp4d1Bv3-xZdBiGgWEnJvkeySg25X4',
    appId: '1:202403588023:ios:3d9ff0336c6bab8f0c6a32',
    messagingSenderId: '202403588023',
    projectId: 'panaderia-d6279',
    databaseURL: 'https://panaderia-d6279-default-rtdb.firebaseio.com',
    storageBucket: 'panaderia-d6279.firebasestorage.app',
    iosBundleId: 'com.example.pancito',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA7KR1EU5zdG7Kp3gDfT1KHWrp8bi5O2dE',
    appId: '1:202403588023:web:f748a52f6866a12f0c6a32',
    messagingSenderId: '202403588023',
    projectId: 'panaderia-d6279',
    authDomain: 'panaderia-d6279.firebaseapp.com',
    databaseURL: 'https://panaderia-d6279-default-rtdb.firebaseio.com',
    storageBucket: 'panaderia-d6279.firebasestorage.app',
  );
}
