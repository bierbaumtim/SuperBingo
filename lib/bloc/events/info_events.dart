import 'package:equatable/equatable.dart';

abstract class InfoEvent extends Equatable {
  const InfoEvent();

  @override
  List<Object> get props => [];
}

class LoadInfos extends InfoEvent {}

class SetPlayerName extends InfoEvent {
  final String playerName;

  const SetPlayerName(this.playerName);

  @override
  List<Object> get props => super.props..add(playerName);
}
