import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const key = 'pin_hash';

  String _hash(String pin) =>
      sha256.convert(utf8.encode(pin)).toString();

  Future<bool> isConfigured() async {
    final p = await SharedPreferences.getInstance();
    return (p.getString(key) ?? '').isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, _hash(pin));
  }

  Future<bool> verifyPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    return p.getString(key) == _hash(pin);
  }
}
