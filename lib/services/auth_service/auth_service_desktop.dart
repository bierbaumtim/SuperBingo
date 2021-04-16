import 'package:firedart/auth/firebase_auth.dart';

import 'auth_service_interface.dart';

class AuthServiceDesktop implements IAuthService {
  @override
  bool get isUserLoggedIn => FirebaseAuth.instance.isSignedIn;

  @override
  String get userId => FirebaseAuth.instance.userId;

  @override
  Future<void> signInAnonymously() => FirebaseAuth.instance.signInAnonymously();
}
