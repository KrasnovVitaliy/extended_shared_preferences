import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:extended_shared_preferences/extended_shared_preferences.dart';
import 'package:encrypt/encrypt.dart';

void initializationTests() {
  test('Try to call set mehod without initizlization', () async {
    try {
      await ExtendedSharedPreferences.setIntWithTTL(key: "test", value: 0, ttl: const Duration(seconds: 5));
    } catch (e) {
      expect(e.toString(), "Exception: Extended Shared Preferences not initialized");
    }
  });

  test('Try to call set mehod with initizlization', () async {
    await ExtendedSharedPreferences.init();
    await ExtendedSharedPreferences.setIntWithTTL(key: "test", value: 0, ttl: const Duration(seconds: 5));
  });
}

void setValuesWithTtlTests() {
  test('Try to set string value with TTL', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    String value = "value";
    await ExtendedSharedPreferences.setStringWithTTL(key: key, value: value, ttl: const Duration(seconds: 1));
    String? v = await ExtendedSharedPreferences.getString(key: key);
    expect(v, value);
    await Future.delayed(const Duration(seconds: 2));
    v = await ExtendedSharedPreferences.getString(key: key);
    expect(v, null);
  });

  test('Try to set int value with TTL', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    int value = 1234;
    await ExtendedSharedPreferences.setIntWithTTL(key: key, value: value, ttl: const Duration(seconds: 1));
    int? v = await ExtendedSharedPreferences.getInt(key: key);
    expect(v, value);
    await Future.delayed(const Duration(seconds: 2));
    v = await ExtendedSharedPreferences.getInt(key: key);
    expect(v, null);
  });

  test('Try to set bool value with TTL', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    bool value = false;
    await ExtendedSharedPreferences.setBoolWithTTL(key: key, value: value, ttl: const Duration(seconds: 1));
    bool? v = await ExtendedSharedPreferences.getBool(key: key);
    expect(v, value);
    await Future.delayed(const Duration(seconds: 2));
    v = await ExtendedSharedPreferences.getBool(key: key);
    expect(v, null);
  });

  test('Try to set string list value with TTL', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    List<String> value = ["test", "string", "list"];
    await ExtendedSharedPreferences.setStringListWithTTL(key: key, value: value, ttl: const Duration(seconds: 1));
    List<String>? v = await ExtendedSharedPreferences.getStringList(key: key);
    expect(v, value);
    await Future.delayed(const Duration(seconds: 2));
    v = await ExtendedSharedPreferences.getStringList(key: key);
    expect(v, null);
  });
}

void removeKeyTests() {
  test('Try Remove key before TTL expire', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    String value = "value";
    await ExtendedSharedPreferences.setStringWithTTL(key: key, value: value, ttl: const Duration(seconds: 10));
    await ExtendedSharedPreferences.remove(key: key);
    String? v = await ExtendedSharedPreferences.getString(key: key);
    expect(v, null);
  });

  test('Try Remove key without TTL', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    String value = "value";
    await ExtendedSharedPreferences.prefs!.setString(key, value);
    await ExtendedSharedPreferences.prefs!.remove(key);
    String? v = ExtendedSharedPreferences.prefs!.getString(key);
    expect(v, null);
  });
}

void setValuesWithRegularPref() {
  test('Try to set string value without TTL', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    String value = "value";
    await ExtendedSharedPreferences.prefs!.setString(key, value);
    String? v = ExtendedSharedPreferences.prefs!.getString(key);
    expect(v, value);
  });

  test('Try to set int value without TTL', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    int value = 1234;
    await ExtendedSharedPreferences.prefs!.setInt(key, value);
    int? v = ExtendedSharedPreferences.prefs!.getInt(key);
    expect(v, value);
  });

  test('Try to set bool value without TTL', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    bool value = true;
    await ExtendedSharedPreferences.prefs!.setBool(key, value);
    bool? v = ExtendedSharedPreferences.prefs!.getBool(key);
    expect(v, value);
  });

  test('Try to set string list value without TTL', () async {
    await ExtendedSharedPreferences.init();
    String key = "test";
    List<String> value = ["test", "string", "list"];
    await ExtendedSharedPreferences.prefs!.setStringList(key, value);
    List<String>? v = ExtendedSharedPreferences.prefs!.getStringList(key);
    expect(v, value);
  });
}

testEncryptedValues() {
  test('Try to set encrypted value', () async {
    String encryptionKey = "VerySimple32LengthEncryptionKey=";
    await ExtendedSharedPreferences.init(encryptionKey: encryptionKey);
    String key = "test";
    String value = "value";
    await ExtendedSharedPreferences.setStringEncrypted(key: key, value: value);
    String? v = ExtendedSharedPreferences.getStringEncrypted(key: key);
    expect(v, value);

    String incorrectEncryptionKey = "incorrect32LengthEncryptionKey==";
    await ExtendedSharedPreferences.init(encryptionKey: incorrectEncryptionKey);
    try {
      v = ExtendedSharedPreferences.getStringEncrypted(key: key);
    } on ArgumentError catch (e) {
      expect(e.message, 'Invalid or corrupted pad block');
    }
  });

  test('Try to set encrypted value with TTL', () async {
    String encryptionKey = "VerySimple32LengthEncryptionKey=";
    await ExtendedSharedPreferences.init(encryptionKey: encryptionKey);
    String key = "test";
    String value = "value";
    await ExtendedSharedPreferences.setStringWithTTLEncrypted(key: key, value: value, ttl: const Duration(seconds: 5));
    String? v = await ExtendedSharedPreferences.getStringWithTTLEncrypted(key: key);
    expect(v, value);

    String incorrectEncryptionKey = "incorrect32LengthEncryptionKey==";
    await ExtendedSharedPreferences.init(encryptionKey: incorrectEncryptionKey);
    try {
      v = await ExtendedSharedPreferences.getStringWithTTLEncrypted(key: key);
    } on ArgumentError catch (e) {
      expect(e.message, 'Invalid or corrupted pad block');
    }
  });

  test('Try to set encrypted string list', () async {
    String encryptionKey = "VerySimple32LengthEncryptionKey=";
    await ExtendedSharedPreferences.init(encryptionKey: encryptionKey);
    String key = "test";
    List<String> value = ["item 0", "item 1", "item 2"];
    await ExtendedSharedPreferences.setStringListEcrypted(key: key, value: value);
    List<String>? v = await ExtendedSharedPreferences.getStringListEncrypted(key: key);
    expect(v, value);
  });

  test('Try to set encrypted string list with TTL', () async {
    String encryptionKey = "VerySimple32LengthEncryptionKey=";
    await ExtendedSharedPreferences.init(encryptionKey: encryptionKey);
    String key = "test";
    List<String> value = ["item 0", "item 1", "item 2"];
    await ExtendedSharedPreferences.setStringListWithTTLEcrypted(key: key, value: value, ttl: const Duration(seconds: 2));
    List<String>? v = await ExtendedSharedPreferences.getStringListEncrypted(key: key);
    expect(v, value);
    await Future.delayed(const Duration(seconds: 2));
    v = await ExtendedSharedPreferences.getStringListEncrypted(key: key);
    expect(v, null);
  });
}

void main() {
  // Need to avoid SharedPreferences preferences exception
  SharedPreferences.setMockInitialValues({});
  initializationTests();
  setValuesWithTtlTests();
  removeKeyTests();
  setValuesWithRegularPref();
  testEncryptedValues();
}
