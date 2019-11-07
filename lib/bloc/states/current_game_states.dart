import 'package:equatable/equatable.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';

abstract class CurrentGameState extends Equatable {
  const CurrentGameState();

  @override
  List<Object> get props => [];
}

class CurrentGameLoaded extends CurrentGameState {
  final Game game;

  const CurrentGameLoaded(this.game);

  @override
  List<Object> get props => super.props..add(game);
}

class CurrentGameEmpty extends CurrentGameState {}

class CurrentGameStarting extends CurrentGameState {}

class PlayerJoined extends CurrentGameState {
  final Player player;

  const PlayerJoined(this.player);
}
