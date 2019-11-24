import 'package:equatable/equatable.dart';

abstract class InfoEvent extends Equatable {
  const InfoEvent();

  @override
  List<Object> get props => [];
}

class LoadInfos extends InfoEvent {}

class CompleteFirstStartConfiguration extends InfoEvent {
  final String playerName;

  const CompleteFirstStartConfiguration(this.playerName);

  @override
  List<Object> get props => super.props..add(playerName);
}

class SetPlayerName extends InfoEvent {
  final String playerName;

  const SetPlayerName(this.playerName);

  @override
  List<Object> get props => super.props..add(playerName);
}
