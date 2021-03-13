import 'package:bloc/bloc.dart';

import '../../models/app_models/player.dart';
import '../../services/information_storage.dart';
import '../../services/log_service.dart';
import '../../services/network_service/network_service_interface.dart';
import '../../utils/configuration_utils.dart';
import '../events/join_game_events.dart';
import '../states/join_game_states.dart';

class JoinGameBloc extends Bloc<JoinGameEvent, JoinGameState> {
  final INetworkService networkService;
  String? gameId;
  String? gameLink;
  String? gamePath;
  late Player _self;

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
    if (gameId!.isEmpty) {
      yield const JoinGameFailed(
        'Dieses Spiel existiert nicht mehr oder konnte nicht gefunden werden. '
        'Bitte versuche es mit einem anderen Spiel erneut.',
      );
      yield WaitingForAction();
    } else {
      try {
        final username = await getUsername();
        _self = Player.create(username);
        final game = await networkService.getGameById(gameId!);
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
      } on Object catch (e, s) {
        await LogService.instance.recordError(e, s);
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
      yield* _mapJoinGameToState(JoinGame(linkData));
    } on UnsupportedGameLinkException catch (e, s) {
      await LogService.instance.recordError(e, s);
      yield const JoinGameFailed('Der Link wird nicht unterstützt.');
      yield WaitingForAction();
    } on Object catch (e, s) {
      await LogService.instance.recordError(e, s);
      yield const JoinGameFailed(
        'Beim Beitreten ist ein Fehler aufgetreten. Versuche es später erneut.',
      );
      yield WaitingForAction();
    }
  }

  String parseGameLink(String link) {
    // superbingo://id:$gameId

    if (link.isNotEmpty &&
        RegExp(r'superbingo:\/\/id:.+').allMatches(link).length == 1) {
      final id = link.replaceAll('superbingo://', '').replaceAll('id:', '');

      return id;
    } else {
      throw UnsupportedGameLinkException();
    }
  }
}

class UnsupportedGameLinkException implements Exception {}
