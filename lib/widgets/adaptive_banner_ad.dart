import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class AdaptiveBannerAd extends StatefulWidget {
  const AdaptiveBannerAd({super.key});

  @override
  State<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends State<AdaptiveBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    await AdService().waitForInit();
    debugPrint('AdaptiveBannerAd: Loading banner...');
    if (!mounted) return;
    final ad = await AdService().createAdaptiveBanner(context);
    if (!mounted) {
      ad?.dispose();
      return;
    }
    debugPrint('AdaptiveBannerAd: Banner loaded: ${ad != null}');
    setState(() {
      _bannerAd = ad;
      _isLoaded = ad != null;
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  // TODO: Remove this flag after taking App Store screenshots
  static const bool _hideForScreenshots = true;

  @override
  Widget build(BuildContext context) {
    if (_hideForScreenshots) return const SizedBox.shrink();
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
