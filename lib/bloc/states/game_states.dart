import 'package:equatable/equatable.dart';
import 'package:superbingo/models/app_models/player.dart';

/// {@template gameconfigurationstate}
///
/// {@endtemplate}
abstract class GameConfigurationState extends Equatable {
  /// {@macro gameconfigurationstate}
  const GameConfigurationState();

  @override
  List<Object> get props => [];
}

/// {@template gamecreated}
/// Spiel wurde erstellt und es wird auf Start des Spiels gewartet
/// {@endtemplate}
class GameCreated extends GameConfigurationState {
  /// Firestore Document-ID des Spiels
  final String gameId;

  /// Link mit spezifischer Zusammensetzung, welcher auf ein Spiel
  /// in Firestore zeigt.
  final String gameLink;

  /// Client-eigenes Spieler-Object
  final Player self;

  /// {@macro gamecreated}
  const GameCreated({
    this.gameId,
    this.gameLink,
    this.self,
  });

  @override
  List<Object> get props => super.props
    ..addAll([
      gameId,
      gameLink,
      self,
    ]);
}

/// {@template gamestarted}
/// [GameStarted] Stellt den State dar, wenn ein Spiel gestartet wurde.
/// {@endtemplate}
class GameStarted extends GameConfigurationState {
  /// Firestore Document-ID des Spiels
  final String gameId;

  /// {@macro gamestarted}
  const GameStarted(this.gameId);

  @override
  List<Object> get props => super.props..addAll([gameId]);
}

/// {@template gamecreating}
/// Spiel wird erstellt
/// {@endtemplate}
class GameCreating extends GameConfigurationState {}

/// {@template gamecreationfailed}
/// Erstellung eines neuen Spiels ist fehlgeschlagen.
/// {@endtemplate}
class GameCreationFailed extends GameConfigurationState {
  /// Fehlermeldung - `Exception.message`
  final String error;

  /// {@macro gamecreationfailed}
  const GameCreationFailed(this.error);

  @override
  List<Object> get props => super.props..add(error);
}

/// {@template waitinggameconfiginput}
/// State in dem das Bloc auf ein neues Event wartet
/// {@endtemplate}
class WaitingGameConfigInput extends GameConfigurationState {}
