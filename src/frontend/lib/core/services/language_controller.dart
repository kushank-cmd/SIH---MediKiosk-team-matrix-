import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import 'bhashini_service.dart';
import 'local_storage_service.dart';

/// App-wide controller managing active Bhashini language, offline Hive caching,
/// live runtime translation loading, and widget tree re-rendering.
class LanguageController extends ChangeNotifier {
  static final LanguageController instance = LanguageController._internal();

  factory LanguageController() => instance;

  LanguageController._internal();
  String _currentLanguageCode = 'en';
  bool _isTranslating = false;
  double _translationProgress = 0.0;
  String get currentLanguageCode => _currentLanguageCode;
  bool get isTranslating => _isTranslating;
  double get translationProgress => _translationProgress;
  final List<Map<String, String>> supportedLanguages = const [
    {'code': 'en', 'name': 'English', 'nativeName': 'English', 'sample': 'Welcome to AYUSH Health Kiosk'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी', 'sample': 'आयुष स्वास्थ्य कियोस्क में आपका स्वागत है'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी', 'sample': 'आयुष आरोग्य केंद्रात आपले स्वागत आहे'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்', 'sample': 'ஆயுஷ் நல்வாழ்வு மையத்திற்கு வரவேற்கிறோம்'},
    {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు', 'sample': 'ఆయుష్ ఆరోగ్య కేంద్రానికి స్వాగతం'},
    {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা', 'sample': 'আয়ুশ স্বাস্থ্য কিয়স্কে স্বাগতম'},
    {'code': 'sa', 'name': 'Sanskrit', 'nativeName': 'संस्कृतम्', 'sample': 'आयुर्वेद समग्र स्वास्थ्य परामर्श मञ्चम्'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી', 'sample': 'આયુષ હેલ્થ કિયોસ્કમાં આપનું સ્વાગત છે'},
    {'code': 'kn', 'name': 'Kannada', 'nativeName': 'ಕನ್ನಡ', 'sample': 'ಆಯುಷ್ ಆರೋಗ್ಯ ಕಿಯೋಸ್ಕ್‌ಗೆ ಸುಸ್ವಾಗತ'},
    {'code': 'ml', 'name': 'Malayalam', 'nativeName': 'മലയാളം', 'sample': 'ആയുഷ് ഹെൽത്ത് കിയോസ്കിലേക്ക് സ്വാഗതം'},
    {'code': 'or', 'name': 'Odia', 'nativeName': 'ଓଡ଼ିଆ', 'sample': 'ଆୟୁଷ ସ୍ୱାସ୍ଥ୍ୟ କିଓସ୍କକୁ ସ୍ୱାଗତ'},
    {'code': 'pa', 'name': 'Punjabi', 'nativeName': 'ਪੰਜਾਬੀ', 'sample': 'ਆਯੂਸ਼ ਹੈਲਥ ਕਿਓਸਕ ਵਿੱਚ ਤੁਹਾਡਾ ਸੁਆਗਤ ਹੈ'},
    {'code': 'as', 'name': 'Assamese', 'nativeName': 'অসমীয়া', 'sample': 'আয়ুষ স্বাস্থ্য কিয়স্কলৈ স্বাগতম'},
    {'code': 'ur', 'name': 'Urdu', 'nativeName': 'اردو', 'sample': 'آیوش ہیلتھ کیوسک میں خوش آمدید'}
  ];

  /// Initializes language state from Hive offline storage at startup.
  Future<void> init() async {
    final savedLang = LocalStorageService.getSelectedLanguage();
    _currentLanguageCode = savedLang;
    AppTranslations.currentLanguage = savedLang;
  }

  /// Changes the application language, invokes Bhashini translation if needed,
  /// saves to Hive, updates [AppTranslations], and notifies all listening screens.
  Future<void> setLanguage(String langCode) async {
    if (langCode == _currentLanguageCode && !_isTranslating) return;

    _isTranslating = true;
    _translationProgress = 0.1;
    notifyListeners();

    try {
      // 1. Check if language has already been translated & cached in Hive
      final cacheKey = '${LocalStorageService.keyBhashiniCachePrefix}$langCode';
      final cachedTranslations = LocalStorageService.getMap(cacheKey);

      if (cachedTranslations != null && cachedTranslations.isNotEmpty) {
        // Fast path: load instantly from Hive cache
        AppTranslations.injectTranslations(
          langCode,
          cachedTranslations.map((k, v) => MapEntry(k, v.toString())),
        );
        _translationProgress = 1.0;
      } else {
        // 2. Initial selection: Batch translate all English app strings via Bhashini
        final englishStrings = AppTranslations.englishStrings;
        _translationProgress = 0.4;
        notifyListeners();

        final translated = await BhashiniService.batchTranslate(englishStrings, langCode);
        _translationProgress = 0.8;
        notifyListeners();

        // Inject into active runtime dictionary
        AppTranslations.injectTranslations(langCode, translated);
      }

      // 3. Update active state
      _currentLanguageCode = langCode;
      AppTranslations.currentLanguage = langCode;

      // 4. Persist to Hive
      await LocalStorageService.setSelectedLanguage(langCode);
    } catch (e) {
      debugPrint('[LanguageController] Error changing language');
      _currentLanguageCode = langCode;
      AppTranslations.currentLanguage = langCode;
    } finally {
      _isTranslating = false;
      _translationProgress = 1.0;
      notifyListeners();
    }
  }
}
