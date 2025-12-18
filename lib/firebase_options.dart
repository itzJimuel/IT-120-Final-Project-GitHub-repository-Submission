import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDMCqGXIxFFh3gcQIstbMkA1Qw9dl5Zvc',
    appId: '1:631367205276:android:5f8bf8549980f14a094859',
    messagingSenderId: '631367205276',
    projectId: 'amuto-carbrandslogo',
    databaseURL: 'https://amuto-carbrandslogo-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'amuto-carbrandslogo.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    databaseURL: 'YOUR_DATABASE_URL',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.example.amuto_carbrandlogos',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDDMCqGXIxFFh3gcQIstbMkA1Qw9dl5Zvc',
    appId: '1:631367205276:web:5f8bf8549980f14a094859',
    messagingSenderId: '631367205276',
    projectId: 'amuto-carbrandslogo',
    databaseURL: 'https://amuto-carbrandslogo-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'amuto-carbrandslogo.firebasestorage.app',
  );
}
