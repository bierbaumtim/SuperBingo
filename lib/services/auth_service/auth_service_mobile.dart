import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service_interface.dart';

class AuthServiceMobile implements IAuthService {
  @override
  bool get isUserLoggedIn => FirebaseAuth.instance.currentUser != null;

  @override
  String get userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<void> signInAnonymously() => FirebaseAuth.instance.signInAnonymously();
}
