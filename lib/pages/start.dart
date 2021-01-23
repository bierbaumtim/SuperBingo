import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import '../bloc/blocs/current_game_bloc.dart';
import '../bloc/blocs/game_configuration_bloc.dart';
import '../bloc/blocs/info_bloc.dart';
import '../bloc/blocs/join_game_bloc.dart';
import '../bloc/blocs/open_games_bloc.dart';
import '../bloc/events/current_game_events.dart'
    show StartGame, OpenGameWaitingLobby;
import '../bloc/events/game_events.dart';
import '../bloc/states/game_states.dart';
import '../bloc/states/info_states.dart';
import '../bloc/states/join_game_states.dart';
import '../constants/enums.dart';
import '../constants/version.dart';
import '../models/app_models/card.dart';
import '../models/app_models/game.dart';
import '../utils/card_utils.dart';
import '../utils/version_utils.dart';
import '../widgets/loading_widget.dart';
import '../widgets/play_card.dart';

/// Startseite
///
/// Hier landet der Spieler nachdem er die App startet
/// Vor hier aus kann zur Spielerstellung, Spielsuche
/// und Spielerkonfiguration navigiert werden.
class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  OverlayEntry _joiningOverlay;

  @override
  void dispose() {
    hideJoiningOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicGamesBloc = Provider.of<PublicGamesBloc>(context);

    return MultiBlocListener(
      listeners: <BlocListener>[
        BlocListener<JoinGameBloc, JoinGameState>(
          listener: (context, state) {
            if (state is JoiningGame) {
              showJoiningOverlay(context);
            } else {
              hideJoiningOverlay();
            }
            if (state is JoinedGame) {
              context.read<CurrentGameBloc>().add(StartGame(
                    gameId: state.gameId,
                    self: state.self,
                  ));
              Navigator.of(context).pushNamed('/game');
            } else if (state is JoinGameFailed) {
              showSimpleNotification(
                Text(state.error),
                foreground: Colors.white,
                slideDismiss: true,
              );
            }
          },
        ),
        BlocListener<GameConfigurationBloc, GameConfigurationState>(
          listener: (context, state) {
            if (state is GameCreated) {
              context.read<CurrentGameBloc>().add(
                    OpenGameWaitingLobby(
                      gameId: state.gameId,
                      self: state.self,
                    ),
                  );
            } else if (state is GameCreationFailed) {
              showSimpleNotification(
                Text(state.error),
                foreground: Colors.white,
                slideDismiss: true,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: BlocBuilder<InfoBloc, InfoState>(
            builder: (context, state) => Text(
              state is InfosLoaded ? 'Hallo ${state.playerName}' : 'Superbingo',
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.pushNamed(context, '/user_page'),
            ),
            if (!kReleaseMode)
              IconButton(
                icon: const Icon(Icons.bug_report),
                onPressed: () => Navigator.of(context).pushNamed('/game'),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: <Widget>[
              LayoutBuilder(
                builder: (context, constraints) {
                  final joinGameCardHeight =
                      constraints.maxHeight * (2 / 3) - 32;
                  final newGameCardHeight =
                      constraints.maxHeight * (1 / 3) - 32;

                  return Center(
                    child: ConstrainedBox(
                      constraints: constraints.copyWith(maxWidth: 600),
                      child: Column(
                        children: <Widget>[
                          Card(
                            margin: const EdgeInsets.all(16),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.orangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: joinGameCardHeight,
                              child: InkWell(
                                onTap: () async => Navigator.of(context)
                                    .pushNamed('/join_game'),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    math.max(16, joinGameCardHeight * 0.05),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Text(
                                              'Spiel beitreten',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline3
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontFamily: 'Roboto',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            StreamBuilder<List<Game>>(
                                              initialData: const [],
                                              stream: publicGamesBloc
                                                  .publicGamesStream,
                                              builder: (context, snapshot) {
                                                final gameCount =
                                                    snapshot.hasData
                                                        ? snapshot.data.length
                                                        : 0;

                                                return Text(
                                                  '$gameCount offene Spiele verfügbar',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1
                                                      .copyWith(
                                                        color: Colors.white
                                                            .withOpacity(.7),
                                                      ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 56,
                                            bottom: 16,
                                          ),
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              final cardHeight = math.min(
                                                constraints.maxHeight * 0.9,
                                                300.0,
                                              );
                                              final cardWidth = cardHeight *
                                                  (100 /
                                                      175); // Use default size to calculate new size while preserving the aspectratio

                                              return Stack(
                                                alignment: Alignment.bottomLeft,
                                                children: <Widget>[
                                                  Builder(
                                                    builder: (_) {
                                                      final rotationValues =
                                                          getRotationAngles(
                                                              0, 3);

                                                      return PlayCard(
                                                        elevation: 2,
                                                        isFlipped: false,
                                                        onCardTap: (_) {},
                                                        card: GameCard(
                                                          color:
                                                              CardColor.heart,
                                                          number:
                                                              CardNumber.seven,
                                                          id: '',
                                                        ),
                                                        angle: rotationValues[
                                                            'angle'],
                                                        rotationAngle:
                                                            rotationValues[
                                                                'rotation'],
                                                        rotationYOffset: 100,
                                                        height: cardHeight,
                                                        width: cardWidth,
                                                      );
                                                    },
                                                  ),
                                                  Builder(
                                                    builder: (_) {
                                                      final rotationValues =
                                                          getRotationAngles(
                                                              2, 3);

                                                      return PlayCard(
                                                        elevation: 2,
                                                        isFlipped: false,
                                                        onCardTap: (_) {},
                                                        card: GameCard(
                                                          color:
                                                              CardColor.diamond,
                                                          number:
                                                              CardNumber.nine,
                                                          id: '',
                                                        ),
                                                        angle: rotationValues[
                                                            'angle'],
                                                        rotationAngle:
                                                            rotationValues[
                                                                'rotation'],
                                                        rotationYOffset: 100,
                                                        height: cardHeight,
                                                        width: cardWidth,
                                                      );
                                                    },
                                                  ),
                                                  PlayCard(
                                                    elevation: 3,
                                                    isFlipped: false,
                                                    onCardTap: (_) {},
                                                    card: GameCard(
                                                      color: CardColor.clover,
                                                      number: CardNumber.eight,
                                                      id: '',
                                                    ),
                                                    height: cardHeight,
                                                    width: cardWidth,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.all(16),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.greenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              height: newGameCardHeight,
                              child: InkWell(
                                onTap: () async {
                                  if (await _checkPlayer(context)) {
                                    await Navigator.of(context)
                                        .pushNamed('/new_game');
                                    BlocProvider.of<GameConfigurationBloc>(
                                            context)
                                        .add(ResetGameConfiguration());
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        'Neues Spiel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3
                                            .copyWith(
                                              color: Colors.white,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Starte dein eigenes Spiel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                              color:
                                                  Colors.white.withOpacity(.7),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: FutureBuilder<bool>(
                      future: checkIfAppWasUpdated,
                      builder: (context, snapshot) {
                        var version = kAppVersion;
                        if (snapshot.hasData && snapshot.data) {
                          version = "$version - Updated";
                        }

                        return Text(version);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkPlayer(BuildContext context) async {
    if (context.read<InfoBloc>().state is! InfosLoaded) {
      final result =
          await Navigator.of(context).pushNamed('/user_page') as String;
      return result != null && result.isNotEmpty;
    }
    return true;
  }

  // String messageByJoiningState(JoiningState state) {
  //   if (state == JoiningState.dataIssue) {
  //     return 'Beim erstellen des Spiels ist ein Fehler aufgetreten. Du kannst diesem Spiel daher nicht beitreten.';
  //   } else if (state == JoiningState.playerAlreadyJoined) {
  //     return 'Beim Verlassen des Spiels ist ein Fehler aufgetreten. Du kannst diesem Spiel daher nicht erneut beitreten.';
  //   } else {
  //     return 'Aufgrund eines Fehler kannst du dem Spiel nicht beitreten. Versuche es bitte später erneut.';
  //   }
  // }

  void showJoiningOverlay(BuildContext context) {
    _joiningOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: <Widget>[
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Material(
              color: Colors.black.withOpacity(0.25),
              child: const Loading(
                content: 'Du trittst dem Spiel bei.',
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_joiningOverlay);
  }

  void hideJoiningOverlay() {
    if (_joiningOverlay != null) {
      _joiningOverlay?.remove();
      _joiningOverlay = null;
    }
  }
}
