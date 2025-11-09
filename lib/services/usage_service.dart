import 'package:shared_preferences/shared_preferences.dart';

class UsageService {
  static const _kFreeLimit = 5;
  static const _kKeyUsed = 'chat_free_used';
  static const _kKeyPro = 'chat_is_pro';

  Future<int> getUsed() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kKeyUsed) ?? 0;
  }

  Future<bool> isPro() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kKeyPro) ?? false;
  }

  Future<void> markPro(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kKeyPro, value);
  }

  Future<void> increment() async {
    final sp = await SharedPreferences.getInstance();
    final used = sp.getInt(_kKeyUsed) ?? 0;
    await sp.setInt(_kKeyUsed, used + 1);
  }

  Future<void> resetFreeCounter() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kKeyUsed);
  }

  int get freeLimit => _kFreeLimit;

  Future<bool> canUse() async {
    final pro = await isPro();
    if (pro) return true;
    final used = await getUsed();
    return used < _kFreeLimit;
  }
}
