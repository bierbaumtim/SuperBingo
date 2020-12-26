import 'package:flutter/foundation.dart';

import '../../models/app_models/game.dart';

abstract class INetworkService {
  const INetworkService();

  Game get previousGame;
  Game get currentGame;
  Stream<Game> get gameChangedStream;

  Future<bool> setupSubscription(String gameId);

  Future<GameMetaInformation> addGame(Game game);

  Future<void> deleteGame(String gameId);

  Future<void> updateGameData(dynamic data, [String gameId]);

  Future<void> cancelSubscription();

  Future<void> restoreHandCards(String playerId);

  Future<void> dispose();

  Future<Game> getGameById(String id);
}

class GameMetaInformation {
  final String id;
  final String path;

  const GameMetaInformation({
    @required this.id,
    @required this.path,
  });
}
