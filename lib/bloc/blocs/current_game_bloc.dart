import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:superbingo/bloc/events/current_game_events.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';
import 'package:superbingo/constants/card_deck.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/models/app_models/rules.dart';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:rxdart/rxdart.dart';

class CurrentGameBloc extends Bloc<CurrentGameEvent, CurrentGameState> {
  Firestore db;
  StreamSubscription gameSub;
  String gameId;
  String gameLink;
  int _playerId;
  Game _game;
  Player _self;

  /// {@macro currentgamebloc}
  CurrentGameBloc() {
    _playedCardsController = BehaviorSubject<List<GameCard>>();
    db ??= Firestore.instance;
  }

  @override
  CurrentGameState get initialState => CurrentGameEmpty();

  @override
  Stream<CurrentGameState> mapEventToState(CurrentGameEvent event) async* {
    if (event is StartGame) {
      yield* _mapStartGameToState(event);
    } else if (event is StartGameWaitingLobby) {
      yield* _mapStartGameWaitingLobbyToState(event);
    } else if (event is LeaveGame) {
      yield* _mapLeaveGameToState(event);
    } else if (event is EndGame) {
    } else if (event is UpdateCurrentGame) {
      yield* _mapUpdateCurrentGameToState(event);
    }
  }

  @override
  Future<void> close() async {
    gameSub.cancel();
    super.close();
  }

  Stream<CurrentGameState> _mapStartGameToState(StartGame event) async* {
    yield CurrentGameStarting();
    final success = await _startGame(event.gameId);
    yield success
        ? CurrentGameLoaded(
            game: _game,
            handCards: _self.cards,
          )
        : CurrentGameStartingFailed();
  }

  Stream<CurrentGameState> _mapStartGameWaitingLobbyToState(StartGameWaitingLobby event) async* {
    yield CurrentGameStarting();
    final success = await _startGame(event.gameId);
    if (success) {
      var game = await _getGameSnapshot(event.gameId);
      game = game.copyWith(state: GameState.waitingForPlayer);
      await _updateGameData(game);
      yield CurrentGameWaitingForPlayer(game: game);
    } else {
      yield CurrentGameStartingFailed();
    }
  }

  Stream<CurrentGameState> _mapUpdateCurrentGameToState(UpdateCurrentGame event) async* {
    final self = getPlayerFromGame(event.game.players, _playerId);
    yield CurrentGameLoaded(
      game: event.game,
      handCards: self.cards,
    );
  }

  Stream<CurrentGameState> _mapLeaveGameToState(LeaveGame event) async* {
    await leaveGame();
    _self = null;
    _playerId = null;
    gameId = null;
    gameLink = null;
    yield CurrentGameEmpty();
  }

  BehaviorSubject<List<GameCard>> _playedCardsController;
  Sink<List<GameCard>> get _playedCardsSink => _playedCardsController.sink;
  Stream<List<GameCard>> get playedCardsStream => _playedCardsController.stream;

  /// Ruft das Spiel, welches gestartet werden soll ab und setzt alle Variablen im Bloc.
  /// Außerdem wird die StreamSubscription gestartet.
  ///
  /// Gab es beim Ausführen der Methode keine Fehler wird die Funktion mit `true` beendet,
  /// tritt ein Fehler auf mit `false`.
  Future<bool> _startGame(String gameId) async {
    if (gameSub != null) {
      try {
        final snapshot = await db.collection('games').document(gameId).get();
        _handleNetworkDataChange(snapshot);
        gameSub = db.collection('games').document(gameId).snapshots().listen(_handleNetworkDataChange);
        return true;
      } on dynamic catch (e, s) {
        Crashlytics.instance.recordError(e, s);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> leaveGame() async {
    return;
    var game = await _getGameSnapshot(gameId);
    game.players.removeWhere((t) => t.id == _self.id);
    gameSub.cancel();
    if (_self.isHost) {
      if (game.players.isNotEmpty) {
        game.players[0] = game.players[0].copyWith(isHost: true);
      } else {
        await db.collection('games').document(gameId).delete();
        return;
      }
    }
    final unplayerdCards = game.unplayedCardStack.toList();
    game = game.copyWith(
      unplayedCardStack: Queue<GameCard>.from(_self.cards.toList() + unplayerdCards),

      /// TODO Überprüfen ob die Reihenfolge so richtig ist, ggf. müssen die unplayedCards des Games als erstes genutzt werden und denn die des Spielers addeirt werden
    );
    final gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, game);
    await db.collection('games').document(gameId).updateData(gameDBData);
  }

  Future<Game> _getGameSnapshot(String gameId) async {
    final snapshot = await db.collection('games').document(gameId).get();
    return Game.fromJson(snapshot.data);
  }

  Future<void> _updateGameData(Game game) async {
    final dbGame = await gameToDbData(game);
    await db.collection('games').document(game.gameID).updateData(dbGame);
  }

  void _handleNetworkDataChange(DocumentSnapshot snapshot) async {
    _game = Game.fromJson(snapshot.data);
    final player = getPlayerFromGame(_game.players, _playerId);
    add(UpdateCurrentGame(_game));
    // _playedCardsSink.add(_game?.playedCardStack?.toList()?.reversed);
  }

  Future<String> playCard(GameCard card) async {
    // if (_game.currentPlayerId != _playerId) return 'Du bist nicht an der Reihe';
    if (!Rules.isCardAllowed(card, _game.topCard)) {
      return 'Du darfst diese Karte nicht legen';
    }

    _self.cards.removeWhere((c) => c == card);
    final index = _game.players.indexWhere((p) => p.id == _self.id);
    final nextPlayer = getNextPlayer(_game.players, _playerId);
    _game.players.replaceRange(index, index + 1, [_self]);
    var filledGame = _game.copyWith(
      playedCardStack: _game.playedCardStack..add(card),
      currentPlayerId: nextPlayer.id,
      players: _game.players,
    );

    final gameDBData = await compute<Game, Map<String, dynamic>>(gameToDbData, filledGame);

    await db.collection('games').document(gameId).updateData(gameDBData);

    return '';
  }

  /// Ruft den Spieler mit der `playerId` aus der `player` Liste.
  /// Ist keiner Vorhanden wird null zurückgegeben.
  Player getPlayerFromGame(List<Player> player, int playerId) {
    if (player.isEmpty) {
      logWarning(
        '[getPlayerFromGame] Player in Game are empty. Can cause problems.',
      );
      return null;
    } else {
      return player.firstWhere((p) => p.id == _playerId, orElse: () => null);
    }
  }

  /// Ruft den Index des Spielers mit der `playerId`,
  /// erhöht dann den Index und gibt den Spieler an diesem
  /// Index zurück.
  ///
  /// Ist der Index gleich dem Ende der Liste, wird der Index wieder auf 0 gesetzt.
  Player getNextPlayer(List<Player> player, int playerId) {
    var index = player?.indexWhere((p) => p.id == playerId) ?? -1;
    if (index + 1 > player.length - 1) {
      index = 0;
    } else {
      index++;
    }
    return player?.elementAt(index);
  }

  static Map<String, dynamic> gameToDbData(Game game) {
    final json = jsonEncode(game);
    return jsonDecode(json);
  }
}
