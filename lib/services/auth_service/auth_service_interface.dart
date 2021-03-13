abstract class IAuthService {
  String? get userId;
  bool get isUserLoggedIn;

  Future<void> signInAnonymously();
}
