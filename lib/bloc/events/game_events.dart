import 'package:equatable/equatable.dart';

abstract class GameConfigurationEvent extends Equatable {
  const GameConfigurationEvent();

  @override
  List<Object> get props => [];
}

class CreateGame extends GameConfigurationEvent {
  final String name;
  final bool isPublic;
  final int maxPlayer;
  final int cardAmount;

  const CreateGame({
    this.name,
    this.isPublic,
    this.maxPlayer,
    this.cardAmount,
  });

  @override
  List<Object> get props => super.props..addAll([name, cardAmount, maxPlayer, isPublic]);
}

class ResetGameConfiguration extends GameConfigurationEvent {}
