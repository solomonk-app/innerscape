import 'dart:io';
import 'package:flutter/foundation.dart';

class AdIds {
  AdIds._();

  // AdMob App IDs (set these in Info.plist and AndroidManifest.xml)
  static const String androidAppId = 'ca-app-pub-8288417026402649~7432465821';
  static const String iosAppId = 'ca-app-pub-8288417026402649~1362569850';

  // Banner
  static String get banner {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-8288417026402649/2363971973'
        : 'ca-app-pub-8288417026402649/3769241346';
  }

  // Interstitial
  static String get interstitial {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-8288417026402649/4061360741'
        : 'ca-app-pub-8288417026402649/2527623502';
  }

  // Rewarded
  static String get rewarded {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    return Platform.isAndroid
        ? 'ca-app-pub-8288417026402649/1425558739'
        : 'ca-app-pub-8288417026402649/4266034988';
  }
}
