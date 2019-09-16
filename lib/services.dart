// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superbingo/models/app_models/game.dart';

/// `NetworkService` provides all functions needed for online multiplayer part of the game.
/// Every incoming and outgoing data will be processed by it.
class NetworkService {
  static final NetworkService instance = NetworkService._internal();

  factory NetworkService() => instance;

  NetworkService._internal();

  Future<String> startGame(Game nGame) async {
    // final gameDoc = Firestore.instance.collection('games').add(nGame.toNetworkJson());
  }
}

/// Actions describing the current game state. 
/// Also each actions are indicators for the UI to start animations or other stuff 
enum Action { playCard, startGame, dealCards }
