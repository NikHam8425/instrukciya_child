import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/child_profile.dart';
import '../data/profile_repository.dart';

class ProfileState extends ChangeNotifier {
  final repo = ProfileRepository();

  UserProfile user = UserProfile.empty;
  ChildProfile? child;

  Future<void> load() async {
    final pair = await repo.loadAll();
    if (pair != null) {
      user = pair.$1;
      child = pair.$2;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserProfile newUser) async {
    user = newUser;
    await repo.saveAll(user: user, child: child);
    notifyListeners();
  }

  Future<void> updateChild(ChildProfile? newChild) async {
    child = newChild;
    await repo.saveAll(user: user, child: child);
    notifyListeners();
  }
}
