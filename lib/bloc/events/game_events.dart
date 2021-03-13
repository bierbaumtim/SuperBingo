import 'package:equatable/equatable.dart';

/// {@template gameevents.gameconfigurationevent}
/// Base Klasse von der alle Events für das [GameConfigurationBloc] erben
/// {@endtemplate}
abstract class GameConfigurationEvent extends Equatable {
  /// {@macro gameevents.gameconfigurationevent}
  const GameConfigurationEvent();

  @override
  List<Object> get props => [];
}

/// {@template gameevents.creategame}
/// Event um ein neues Spiel zu erstellen und in der
/// DB zu speichern
/// {@endtemplate}
class CreateGame extends GameConfigurationEvent {
  /// Name des Spiels
  final String name;

  /// Konfiguration, ob das Spiel öffentlich ist.
  final bool isPublic;

  /// Konfiguration, wie viele Spieler maximal mitspielen können
  final int maxPlayer;

  /// Konfiguration, mit wie vielen Kartendecks gespielt werden soll
  final int decksAmount;

  /// {@macro gameevents.creategame}
  const CreateGame({
    required this.name,
    this.isPublic = true,
    this.maxPlayer = 6,
    this.decksAmount = 1,
  });

  @override
  List<Object> get props => super.props
    ..addAll(<Object>[
      name,
      decksAmount,
      maxPlayer,
      isPublic,
    ]);
}

/// Event um das Bloc wieder in den Wartezustand zuversetzen
class ResetGameConfiguration extends GameConfigurationEvent {}

/// Event um das konfigurierte Spiel wieder zu löschen
class DeleteConfiguredGame extends GameConfigurationEvent {}
