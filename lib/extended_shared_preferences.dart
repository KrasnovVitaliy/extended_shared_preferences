library extended_shared_preferences;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:extended_shared_preferences/cipher.dart';

class ExtendedSharedPreferences {
  static const String _keyPrefix = 'ttl_';
  static String? _encryptionKey;
  static SharedPreferences? prefs;

  static Future<void> init({String? encryptionKey}) async {
    prefs = await SharedPreferences.getInstance();
    _encryptionKey = encryptionKey;
  }

  // ================================= //
  // Encrypted values in the store //
  // ================================ //
  static Future<void> setStringEncrypted({required String key, required String value}) async {
    _isPrefsInitialized();
    if (_encryptionKey == null) {
      throw Exception("Encryption key not specify");
    }
    await prefs!.setString(key, encrypt(key: _encryptionKey!, plainData: value));
  }

  static String? getStringEncrypted({required String key}) {
    if (_encryptionKey == null) {
      throw Exception("Encryption key not specify");
    }

    String? value = prefs!.getString(key);
    if (value == null) {
      return null;
    }
    return decrypt(key: _encryptionKey!, encryptedData: value);
  }

  static Future<void> setStringWithTTLEncrypted({required String key, required String value, required Duration ttl}) async {
    if (_encryptionKey == null) {
      throw Exception("Encryption key not specify");
    }
    await setStringWithTTL(key: key, value: encrypt(key: _encryptionKey!, plainData: value), ttl: ttl);
  }

  static Future<String?> getStringWithTTLEncrypted({required String key}) async {
    _isPrefsInitialized();
    if (_encryptionKey == null) {
      throw Exception("Encryption key not specify");
    }

    String? value = await getString(key: key);
    if (value == null) {
      return null;
    }
    return decrypt(key: _encryptionKey!, encryptedData: value);
  }

  // ======================= //
  // Set values in the store //
  // ======================= //
  static Future<void> setStringWithTTL({required String key, required String value, required Duration ttl}) async {
    _isPrefsInitialized();
    await prefs!.setString(_getPrefixedKey(key), value);
    await prefs!.setInt(_getExpiryKey(key), _getExpiry(ttl).millisecondsSinceEpoch);
  }

  static Future<void> setIntWithTTL({required String key, required int value, required Duration ttl}) async {
    _isPrefsInitialized();
    await prefs!.setInt(_getPrefixedKey(key), value);
    await prefs!.setInt(_getExpiryKey(key), _getExpiry(ttl).millisecondsSinceEpoch);
  }

  static Future<void> setBoolWithTTL({required String key, required bool value, required Duration ttl}) async {
    _isPrefsInitialized();
    await prefs!.setBool(_getPrefixedKey(key), value);
    await prefs!.setInt(_getExpiryKey(key), _getExpiry(ttl).millisecondsSinceEpoch);
  }

  static Future<void> setStringList({required String key, required List<String> value, required Duration ttl}) async {
    _isPrefsInitialized();
    await prefs!.setStringList(_getPrefixedKey(key), value);
    await prefs!.setInt(_getExpiryKey(key), _getExpiry(ttl).millisecondsSinceEpoch);
  }

  // ========================== //
  //  Get values from the store //
  // ========================= //
  static Future<String?> getString({required String key}) async {
    _isPrefsInitialized();
    String? value = prefs!.getString(_getPrefixedKey(key));
    return await _validateExpireAndreturnValue(key, value);
  }

  static Future<int?> getInt({required String key}) async {
    _isPrefsInitialized();
    int? value = prefs!.getInt(_getPrefixedKey(key));
    return await _validateExpireAndreturnValue(key, value);
  }

  static Future<bool?> getBool({required String key}) async {
    _isPrefsInitialized();
    bool? value = prefs!.getBool(_getPrefixedKey(key));
    return await _validateExpireAndreturnValue(key, value);
  }

  static Future<List<String>?> getStringList({required String key}) async {
    _isPrefsInitialized();
    List<String>? value = prefs!.getStringList(_getPrefixedKey(key));
    return await _validateExpireAndreturnValue(key, value);
  }

  // Remove a key-value pair
  static Future<void> remove({required String key}) async {
    await _removeKeyAndExpiryKey(key);
  }

  static void _isPrefsInitialized() {
    if (prefs == null) {
      throw Exception("Extended Shared Preferences not initialized");
    }
  }

  static String _getPrefixedKey(String key) {
    return _keyPrefix + key; // Prefix the key with TTL
  }

  static String _getExpiryKey(String key) {
    return '${_getPrefixedKey(key)}/_expiry'; // Prefix the key with TTL
  }

  static bool _isKeyExpire(String key) {
    int? expiry = prefs!.getInt(_getExpiryKey(key));
    if (expiry == null) {
      return true;
    }
    DateTime now = DateTime.now();
    if (now.millisecondsSinceEpoch > expiry) {
      return true;
    }
    return false;
  }

  static Future<void> _removeKeyAndExpiryKey(String key) async {
    await prefs!.remove(_getPrefixedKey(key));
    await prefs!.remove(_getExpiryKey(key));
  }

  static DateTime _getExpiry(Duration ttl) {
    DateTime now = DateTime.now();
    return now.add(ttl); // Calculate expiry time
  }

  static Future<dynamic> _validateExpireAndreturnValue(String key, dynamic value) async {
    if (value != null) {
      if (!_isKeyExpire(key)) {
        return value;
      } else {
        await _removeKeyAndExpiryKey(key);
        return null;
      }
    }
    return null;
  }
}
