import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../models/app_models/game.dart';
import '../../models/app_models/player.dart';
import '../../service/information_storage.dart';
import '../../services/network_service.dart';
import '../../utils/configuration_utils.dart';
import '../events/join_game_events.dart';
import '../states/join_game_states.dart';

class JoinGameBloc extends Bloc<JoinGameEvent, JoinGameState> {
  final INetworkService networkService;
  String gameId;
  String gameLink;
  String gamePath;
  Player _self;

  JoinGameBloc(this.networkService) : super(JoiningGame());

  @override
  Stream<JoinGameState> mapEventToState(
    JoinGameEvent event,
  ) async* {
    if (event is JoinGame) {
      yield* _mapJoinGameToState(event);
    } else if (event is JoinWithLink) {
      yield* _mapJoinWithLinkToState(event);
    }
  }

  Stream<JoinGameState> _mapJoinGameToState(JoinGame event) async* {
    yield JoiningGame();
    gameId = event.gameId;
    if (gameId == null || gameId.isEmpty) {
      yield const JoinGameFailed(
        'Dieses Spiel existiert nicht mehr oder konnte nicht gefunden werden. '
        'Bitte versuche es mit einem anderen Spiel erneut.',
      );
      yield WaitingForAction();
    } else {
      try {
        final username = await getUsername();
        _self = Player.create(username);
        final snapshot =
            await networkService.db.collection('games').document(gameId).get();
        final game = Game.fromJson(snapshot.map);
        if (game.players.length + 1 > game.maxPlayer) {
          yield const JoinGameFailed(
            'Die maximale Spieleranzahl für dieses Spiel ist erreicht. '
            'Du kannst diesem Spiel daher nicht mehr beitreten.',
          );
        } else if (game.players.indexWhere((p) => p.id == _self.id) >= 0) {
          yield const JoinGameFailed(
            'Beim Verlassen des Spiels ist ein Fehler aufgetreten. '
            'Du kannst diesem Spiel daher nicht erneut beitreten.',
          );
        } else {
          final cardStack = game.unplayedCardStack;
          if (game.isRunning) {
            _self.drawCards(cardStack);
          }
          game.addPlayer(_self);
          final filledGame = game.copyWith(
            unplayedCardStack: cardStack,
          );

          await networkService.updateGameData(filledGame);

          InformationStorage.instance.gameId = filledGame.gameID;
          InformationStorage.instance.playerId = _self.id;

          yield JoinedGame(
            gameId: filledGame.gameID,
            self: _self,
          );
        }
      } on dynamic catch (e, s) {
        await FirebaseCrashlytics.instance.recordError(e, s);
        yield const JoinGameFailed(
          'Beim Beitreten ist ein Fehler aufgetreten. Versuche es später erneut.',
        );
        yield WaitingForAction();
      }
    }
  }

  Stream<JoinGameState> _mapJoinWithLinkToState(JoinWithLink event) async* {
    try {
      final linkData = parseGameLink(event.gameLink);
      yield* _mapJoinGameToState(JoinGame(linkData['gameid'] as String));
    } on UnsupportedGameLinkException catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(e, s);
      yield const JoinGameFailed('Der Link wird nicht unterstützt.');
      yield WaitingForAction();
    } on dynamic catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(e, s);
      yield const JoinGameFailed(
        'Beim Beitreten ist ein Fehler aufgetreten. Versuche es später erneut.',
      );
      yield WaitingForAction();
    }
  }

  Map<String, dynamic> parseGameLink(String link) {
    // superbingo://id:$gameId|name:${game.name}

    final parts = link.replaceAll('superbingo://', '').split('|');
    if (parts.isNotEmpty) {
      final id = parts.first.replaceAll('id:', '');
      final name = parts.last.replaceAll('name:', '');

      return <String, dynamic>{
        'gameid': id,
        'gamename': name,
      };
    } else {
      throw UnsupportedGameLinkException();
    }
  }
}

class UnsupportedGameLinkException implements Exception {}
