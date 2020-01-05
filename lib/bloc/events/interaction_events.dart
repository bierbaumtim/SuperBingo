import 'package:equatable/equatable.dart';

abstract class InteractionEvent extends Equatable {
  const InteractionEvent();

  @override
  List get props => <Object>[];
}

class CallBingo extends InteractionEvent {}

class CallSuperBingo extends InteractionEvent {}
