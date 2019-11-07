import 'package:equatable/equatable.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';

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
/// um die UI zu aktualisieren.
/// {@mendtemplate}
class CurrentGameLoaded extends CurrentGameState {
  /// Aktuelles Game Objekt
  final Game game;

  /// Handkarten des Spielers
  final List<GameCard> handCards;

  /// {@macro currentgameloaded}
  const CurrentGameLoaded({this.game, this.handCards});

  @override
  List<Object> get props => super.props..add(game);
}

/// State der eine
class CurrentGameEmpty extends CurrentGameState {}

/// State der die Erstellung des Spiels darstellt und
/// einen Loadingscreen hervorruft
class CurrentGameStarting extends CurrentGameState {}

/// Der Start des Spiels ist fehlgeschlagen.
class CurrentGameStartingFailed extends CurrentGameState {}

class PlayerJoined extends CurrentGameState {
  final Player player;

  const PlayerJoined(this.player);
}
