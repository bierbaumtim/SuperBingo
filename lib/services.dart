// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superbingo/models/app_models/game.dart';

class NetworkService {
  static final NetworkService instance = NetworkService._internal();

  factory NetworkService() => instance;

  NetworkService._internal();

  Future<String> startGame(Game nGame) async {
    // final gameDoc = Firestore.instance.collection('games').add(nGame.toNetworkJson());
  }
}
