import 'package:equatable/equatable.dart';
import 'package:superbingo/models/app_models/player.dart';

abstract class GameConfigurationState extends Equatable {
  const GameConfigurationState();

  @override
  List<Object> get props => [];
}

/// Spiel wurde erstellt und es wird auf Start des Spiels gewartet
class GameCreated extends GameConfigurationState {
  final String gameId, gameLink;
  final Player self;

  const GameCreated({
    this.gameId,
    this.gameLink,
    this.self,
  });

  @override
  List<Object> get props => super.props
    ..addAll([
      gameId,
      gameLink,
      self,
    ]);
}

/// Spiel wurde gestartet
class GameStarted extends GameConfigurationState {
  final String gameId;

  const GameStarted(this.gameId);

  @override
  List<Object> get props => super.props..addAll([gameId]);
}

/// Spiel wird erstellt
class GameCreating extends GameConfigurationState {}

class GameCreationFailed extends GameConfigurationState {
  final String error;

  const GameCreationFailed(this.error);

  @override
  List<Object> get props => super.props..add(error);
}

class WaitingGameConfigInput extends GameConfigurationState {}
