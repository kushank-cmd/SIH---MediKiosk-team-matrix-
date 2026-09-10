import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String boxName = 'medikiosk_box';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyHomeTutorialShown = 'home_tutorial_shown';
  static const String keyLastLoginTab = 'last_login_tab';
  static const String keyPatientProfile = 'patient_profile';
  static const String keyFamilyMembers = 'family_members';
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyBhashiniCachePrefix = 'bhashini_cache_';

  static Box? _box;
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  static Box get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError('LocalStorageService has not been initialized. Call LocalStorageService.init() in main.dart');
    }
    return _box!;
  }

  // ==========================================
  // PRIMITIVE GETTERS & SETTERS
  // ==========================================

  static Future<void> saveString(String key, String value) async {
    await box.put(key, value);
    // TODO(Firestore): When cloud sync is active, queue string key-value sync to Firestore /users/{uid}/preferences/{key}
  }

  static String getString(String key, [String defaultValue = '']) {
    return box.get(key, defaultValue: defaultValue) as String;
  }

  static Future<void> saveBool(String key, bool value) async {
    await box.put(key, value);
    // TODO(Firestore): Sync boolean flag (e.g. tutorialSeen, consentAgreed) to Firestore user profile document.
  }

  static bool getBool(String key, [bool defaultValue = false]) {
    return box.get(key, defaultValue: defaultValue) as bool;
  }

  static Future<void> saveInt(String key, int value) async {
    await box.put(key, value);
  }

  static int getInt(String key, [int defaultValue = 0]) {
    return box.get(key, defaultValue: defaultValue) as int;
  }

  static Future<void> saveMap(String key, Map<String, dynamic> value) async {
    // Stored as JSON string or native Hive Map for maximum serialization safety
    await box.put(key, jsonEncode(value));
    // TODO(Firestore): Sync document object to Firestore collection (e.g. /patients/{abhaId} or /consultations).
  }

  static Map<String, dynamic>? getMap(String key) {
    final raw = box.get(key);
    if (raw == null) return null;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String) {
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveList(String key, List<dynamic> value) async {
    await box.put(key, jsonEncode(value));
    // TODO(Firestore): Batch write array items into Firestore sub-collections (e.g. /patients/{id}/family_members).
  }

  static List<dynamic>? getList(String key) {
    final raw = box.get(key);
    if (raw == null) return null;
    if (raw is List) return raw;
    if (raw is String) {
      try {
        return jsonDecode(raw) as List<dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clear(String key) async {
    await box.delete(key);
  }

  static Future<void> clearAll() async {
    await box.clear();
  }

  // ==========================================
  // CONVENIENCE DOMAIN HELPERS
  // ==========================================

  static String getSelectedLanguage() => getString(keySelectedLanguage, 'en');
  static Future<void> setSelectedLanguage(String code) => saveString(keySelectedLanguage, code);

  static bool isHomeTutorialShown() => getBool(keyHomeTutorialShown, false);
  static Future<void> setHomeTutorialShown(bool shown) => saveBool(keyHomeTutorialShown, shown);

  static int getLastLoginTab() => getInt(keyLastLoginTab, 0);
  static Future<void> setLastLoginTab(int index) => saveInt(keyLastLoginTab, index);

  static bool isDarkMode() => getBool(keyIsDarkMode, false);
  static Future<void> setDarkMode(bool dark) => saveBool(keyIsDarkMode, dark);

  static Map<String, dynamic>? getPatientProfile() => getMap(keyPatientProfile);
  static Future<void> setPatientProfile(Map<String, dynamic> data) => saveMap(keyPatientProfile, data);

  static List<dynamic>? getFamilyMembers() => getList(keyFamilyMembers);
  static Future<void> setFamilyMembers(List<dynamic> members) => saveList(keyFamilyMembers, members);
}
