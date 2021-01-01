import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

import '../../constants/enums.dart';
import '../../models/app_models/game.dart';
import '../../models/app_models/player.dart';

/// {@template currentgamestate}
/// Stellt die verschiedenen States des CurrentGameBloc dar und
/// ruft eine Änderung an der UI hervor
/// {@endtemplate}
abstract class CurrentGameState extends Equatable {
  /// {@macro currentgamestate}
  const CurrentGameState();

  @override
  List<Object> get props => [];
}

/// {@template currentgameloaded}
/// Das Spiel ist fertig geladen und hält das aktuelle Game Objekt,
/// das clientseitige Player Objekt und weitere Kennzeichen
/// um die UI zu aktualisieren.
/// {@mendtemplate}
class CurrentGameLoaded extends CurrentGameState {
  /// Aktuelles Game Objekt
  final Game game;

  /// Client-abhängiges Player Object
  final Player self;

  /// Steuert, ob ein Spieler eine Karten aus
  /// der Kartenhand ablegen darf oder nicht.
  final bool canDrawCards;

  /// {@macro currentgameloaded}
  const CurrentGameLoaded({
    @required this.game,
    @required this.self,
    this.canDrawCards = true,
  });

  @override
  List<Object> get props => super.props
    ..addAll([
      game,
      self,
      canDrawCards,
    ]);
}

class CurrentGameWaitingForPlayer extends CurrentGameState {
  /// Aktuelles Game Objekts
  final Game game;

  final Player self;

  const CurrentGameWaitingForPlayer({this.game, this.self});

  @override
  List<Object> get props => super.props..addAll([game, self]);
}

/// State der eine
class CurrentGameEmpty extends CurrentGameState {}

/// State der die Erstellung des Spiels darstellt und
/// einen Loadingscreen hervorruft
class CurrentGameStarting extends CurrentGameState {}

/// Der Start des Spiels ist fehlgeschlagen.
class CurrentGameStartingFailed extends CurrentGameState {}

/// Das Spiel wurde komplett beendet. Triggert, dass die
/// Spieleseite geschlossen wird.
class CurrentGameFinished extends CurrentGameState {}

/// State, um Countdown für Bingo/SuperBingo Call zu starten.
class WaitForBingoCall extends CurrentGameState {
  final bool isSuperBingo;

  const WaitForBingoCall({this.isSuperBingo});

  @override
  List get props => super.props..add(isSuperBingo);
}

/// State, um Overlay anzuzeigen, welche Farbe gewünscht wurde.
class UserChangedAllowedCardColor extends CurrentGameState {
  final CardColor cardColor;

  const UserChangedAllowedCardColor(this.cardColor);

  @override
  List<Object> get props => super.props..add(cardColor);
}
