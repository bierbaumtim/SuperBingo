import 'package:equatable/equatable.dart';

import '../../models/app_models/player.dart';

abstract class JoinGameState extends Equatable {
  const JoinGameState();

  @override
  List<Object> get props => [];
}

class JoiningGame extends JoinGameState {}

class JoinedGame extends JoinGameState {
  final String gameId;
  final Player self;

  JoinedGame({
    this.gameId,
    this.self,
  });

  @override
  List<Object> get props => super.props..addAll([gameId, self]);
}

class JoinGameFailed extends JoinGameState {
  final String error;

  const JoinGameFailed(this.error);

  @override
  List<Object> get props => super.props..add(error);
}

class WaitingForAction extends JoinGameState {}
