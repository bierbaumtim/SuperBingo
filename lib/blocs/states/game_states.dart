import 'package:equatable/equatable.dart';
import 'package:superbingo/models/app_models/player.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object> get props => [];
}

/// Spiel wurde erstellt und es wird auf Start des Spiels gewartet
class GameCreated extends GameState {
  final String playerId;
  final List<Player> player;

  const GameCreated(this.playerId, this.player);

  @override
  List<Object> get props => super.props..addAll([playerId, player]);
}

/// Spiel wurde gestartet
class GameStarted extends GameState {
  final String gameId;

  const GameStarted(this.gameId);

  @override
  List<Object> get props => super.props..addAll([gameId]);
}
