import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentService {
  static final ConsentService _instance = ConsentService._();
  factory ConsentService() => _instance;
  ConsentService._();

  bool _hasRequestedConsent = false;

  /// Call this from main() before runApp — handles only UMP consent.
  /// ATT must be requested separately after the first frame renders.
  Future<void> requestConsent() async {
    try {
      await _requestUmpConsent().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('ConsentService: UMP consent timed out, continuing in limited mode');
        },
      );
    } catch (e) {
      debugPrint('ConsentService: Error requesting UMP consent: $e');
    }
  }

  /// Call this after the first frame has rendered (e.g. from initState).
  /// ATT will silently fail if called before the UI is visible.
  Future<void> requestATTIfNeeded() async {
    if (_hasRequestedConsent) return;
    _hasRequestedConsent = true;

    if (!Platform.isIOS) return;

    try {
      // Wait for the next frame to ensure the app is fully visible
      await Future.delayed(const Duration(milliseconds: 500));
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('ConsentService: ATT current status: $status');
      if (status == TrackingStatus.notDetermined) {
        final result = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('ConsentService: ATT result: $result');
      }
    } on PlatformException catch (e) {
      debugPrint('ConsentService: ATT error (expected on simulator): $e');
    } catch (e) {
      debugPrint('ConsentService: ATT error: $e');
    }
  }

  Future<void> _requestUmpConsent() async {
    final params = ConsentRequestParameters();
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        debugPrint('ConsentService: UMP info updated');
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _showConsentForm(completer);
        } else {
          debugPrint('ConsentService: No consent form needed');
          completer.complete();
        }
      },
      (error) {
        debugPrint('ConsentService: UMP error: ${error.message}');
        completer.complete();
      },
    );

    await completer.future;
  }

  void _showConsentForm(Completer<void> completer) {
    ConsentForm.loadConsentForm(
      (consentForm) {
        consentForm.show((formError) {
          if (formError != null) {
            debugPrint('ConsentService: Form error: ${formError.message}');
          }
          completer.complete();
        });
      },
      (formError) {
        debugPrint('ConsentService: Failed to load form: ${formError.message}');
        completer.complete();
      },
    );
  }
}
