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

class JoinWithLink extends JoinGameEvent {
  final String gameLink;

  const JoinWithLink(this.gameLink);

  @override
  List<Object> get props => super.props..add(gameLink);
}
