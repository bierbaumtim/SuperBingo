import 'package:equatable/equatable.dart';
import 'package:superbingo/models/app_models/player.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object> get props => [];
}

/// Spiel wurde erstellt und es wird auf Start des Spiels gewartet
class GameCreated extends GameState {
  final String gameId, gameLink;
  final List<Player> player;

  const GameCreated({
    this.gameId,
    this.player,
    this.gameLink,
  });

  @override
  List<Object> get props => super.props..addAll([gameId, player, gameLink]);
}

/// Spiel wurde gestartet
class GameStarted extends GameState {
  final String gameId;

  const GameStarted(this.gameId);

  @override
  List<Object> get props => super.props..addAll([gameId]);
}

/// Spiel wird erstellt
class GameCreating extends GameState {}
