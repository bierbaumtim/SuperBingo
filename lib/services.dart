import 'package:cloud_firestore/cloud_firestore.dart';

class NetworkService {
  static final NetworkService instance = NetworkService._internal();

  factory NetworkService() => instance;

  NetworkService._internal();

  Future<String> startGame(NetworkGame nGame) async {
    final gameDoc = Firestore.instance.collection('games').add(nGame.asJson());
  }
}
