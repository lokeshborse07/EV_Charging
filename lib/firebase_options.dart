// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
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
    apiKey: 'AIzaSyBxpJ_EXkLTx1iWdBegwn-RGOP6kQnw-AY',
    appId: '1:150357300875:web:955c6dd8d280e3415f268e',
    messagingSenderId: '150357300875',
    projectId: 'randomev-station',
    authDomain: 'randomev-station.firebaseapp.com',
    storageBucket: 'randomev-station.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBtRkjCexlkcN4cfLIHcdFhSXruAnyhcOQ',
    appId: '1:150357300875:android:ce0a4084eb304b1e5f268e',
    messagingSenderId: '150357300875',
    projectId: 'randomev-station',
    storageBucket: 'randomev-station.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAzkhOLu6rw1YG1kA_S0OMuGsXhWrI1X44',
    appId: '1:150357300875:ios:3ddeb896937436395f268e',
    messagingSenderId: '150357300875',
    projectId: 'randomev-station',
    storageBucket: 'randomev-station.firebasestorage.app',
    iosBundleId: 'com.example.evcharging.evCharging',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAzkhOLu6rw1YG1kA_S0OMuGsXhWrI1X44',
    appId: '1:150357300875:ios:3ddeb896937436395f268e',
    messagingSenderId: '150357300875',
    projectId: 'randomev-station',
    storageBucket: 'randomev-station.firebasestorage.app',
    iosBundleId: 'com.example.evcharging.evCharging',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBxpJ_EXkLTx1iWdBegwn-RGOP6kQnw-AY',
    appId: '1:150357300875:web:f9677f580b90d5ab5f268e',
    messagingSenderId: '150357300875',
    projectId: 'randomev-station',
    authDomain: 'randomev-station.firebaseapp.com',
    storageBucket: 'randomev-station.firebasestorage.app',
  );
}
