import 'package:equatable/equatable.dart';

abstract class InteractionState extends Equatable {
  const InteractionState();
}

class InitialInteractionState extends InteractionState {
  @override
  List<Object> get props => [];
}
