import 'package:equatable/equatable.dart';

abstract class JoinGameEvent extends Equatable {
  const JoinGameEvent();

  @override
  List<Object> get props => [];
}

class JoinGame extends JoinGameEvent {
  final String gameId;

  const JoinGame(this.gameId);

  @override
  List<Object> get props => super.props..add(gameId);
}
