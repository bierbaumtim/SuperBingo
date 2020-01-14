import 'package:equatable/equatable.dart';

import '../../constants/enums.dart';
import '../../models/app_models/card.dart';
import '../../models/app_models/game.dart';
import '../../models/app_models/player.dart';

abstract class CurrentGameEvent extends Equatable {
  const CurrentGameEvent();

  @override
  List<Object> get props => [];
}

/// {@template currentgameevents.startgame}
/// Event, dass startet das Spiel mit der `gameId`
/// {@endtemplate}
class StartGame extends CurrentGameEvent {
  /// Firestore Document ID, die auf ein Spiel-Datensatz in der DB verweist
  final String gameId;

  /// Client-abhängige Spieler-Object
  final Player self;

  /// {@macro currentgameevents.startgame}
  const StartGame({this.gameId, this.self});

  @override
  List<Object> get props => super.props..addAll([gameId, self]);
}

/// {@template currentgameevents.opengamewaitinglobby}
/// Event, um zur Lobby des Spiels zu gelangen.
/// {@endtemplate}
class OpenGameWaitingLobby extends CurrentGameEvent {
  /// Firestore Document ID, die auf ein Spiel-Datensatz in der DB verweist
  final String gameId;

  /// Client-abhängige Spieler-Object
  final Player self;

  /// {@macro currentgameevents.opengamewaitinglobby}
  const OpenGameWaitingLobby({
    this.gameId,
    this.self,
  });

  @override
  List<Object> get props => super.props..addAll([gameId, self]);
}

/// Event um das aktuelle Spiel zu verlassen
class LeaveGame extends CurrentGameEvent {}

/// Event um das aktuelle Spiel zu beenden
class EndGame extends CurrentGameEvent {}

/// {@template currentgameevents.updatecurrengame}
/// Event, um zur Lobby des Spiels zu gelangen.
/// {@endtemplate}
class UpdateCurrentGame extends CurrentGameEvent {
  /// Spiel-Object mit dem das aktuelle Spiel-Object im Bloc aktualisiert wird
  final Game game;

  /// {@macro currentgameevents.updatecurrengame}
  const UpdateCurrentGame(this.game);

  @override
  List<Object> get props => super.props..add(game);
}

/// {@template currentgameevents.playcard}
/// Event um eine Karte zu legen
/// {@endtemplate}
class PlayCard extends CurrentGameEvent {
  /// Karte die gelegt werden soll
  final GameCard card;

  /// gewünschte Kartenfarbe, wenn ein Bube/Joker gelegt wird
  final CardColor allowedCardColor;

  /// {@macro currentgameevents.playcard}
  const PlayCard(this.card, [this.allowedCardColor]);

  @override
  List<Object> get props => super.props..addAll([card, allowedCardColor]);
}

/// {@template currentgameevents.pullcard}
/// Event um eine Karte zu ziehen
/// {@endtemplate}
class DrawCard extends CurrentGameEvent {
  // /// Karte die gezogen wird
  // final GameCard card;

  /// {@macro currentgameevents.pullcard}
  const DrawCard();

  // @override
  // List<Object> get props => super.props..add(card);
}

class DrawPenaltyCard extends CurrentGameEvent {}
