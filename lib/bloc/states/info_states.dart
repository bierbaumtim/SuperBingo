import 'package:equatable/equatable.dart';

abstract class InfoState extends Equatable {
  const InfoState();

  @override
  List<Object> get props => [];
}

class InfosEmpty extends InfoState {}

class InfosLoading extends InfoState {}

class InfosLoaded extends InfoState {
  final String playerName;
  final int playerId;

  const InfosLoaded({this.playerName, this.playerId});

  @override
  List<Object> get props => super.props..addAll([playerName, playerId]);
}

class FirstStart extends InfoState {}
