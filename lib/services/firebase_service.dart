import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_core/firebase_core.dart';
// import 'package:firedart/firedart.dart';

import '../auth/secure_storage_interface.dart';
import '../auth/secure_token_repository.dart';
import '../auth/secure_token_store.dart';
import '../constants/firestore_data.dart';
import '../utils/configuration_utils.dart';
import 'network_service/network_service_desktop.dart';
import 'network_service/network_service_interface.dart';
import 'network_service/network_service_mobile.dart';

class FirebaseService {
  static final FirebaseService instance = FirebaseService._();

  factory FirebaseService() => instance;

  FirebaseService._();

  Future<void> initFirebase() async {
    if (isDesktop) {
      await _initFiredart();
    } else {
      await _initFirebase();
    }
  }

  Future<void> _initFiredart() async {
    // final tokenRepo = SecureTokenRepository(ISecureStorage());
    // await tokenRepo.loadToken();

    // FirebaseAuth.initialize(kFirestoreApiKey, SecureTokenStore(tokenRepo));
    // Firestore.initialize(kFirestoreProjectId);
  }

  Future<void> _initFirebase() async {
    await Firebase.initializeApp();
  }

  INetworkService get networkService =>
      NetworkServiceMobile(FirebaseFirestore.instance);

  // INetworkService get networkService => isDesktop
  //     ? NetworkServiceDesktop(Firestore.instance)
  //     : NetworkServiceMobile(FirebaseFirestore.instance);
}
