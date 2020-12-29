import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../bloc/blocs/current_game_bloc.dart';
import '../bloc/blocs/interaction_bloc.dart';
import '../bloc/events/current_game_events.dart'
    show LeaveGame, DrawCard, StartGame, EndGame;
import '../bloc/events/interaction_events.dart';
import '../bloc/states/current_game_states.dart';
import '../constants/enums.dart';
import '../constants/ui_constants.dart';
import '../models/app_models/card.dart';
import '../models/app_models/game.dart';
import '../models/app_models/player.dart';
import '../services/share_service/share_service_interface.dart';
import '../utils/dialogs.dart';
import '../widgets/avatars/player_avatars.dart';
import '../widgets/card_scroll_view.dart';
import '../widgets/card_stack.dart';
import '../widgets/horizontal_card_listview.dart';
import '../widgets/loading_widget.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  OverlayEntry startingOverlay;
  bool showCallBingoButton, isSuperBingo;
  PanelController panelController;

  @override
  void initState() {
    super.initState();
    showCallBingoButton = false;
    isSuperBingo = false;
    panelController = PanelController();
  }

  @override
  void dispose() {
    hideStartingOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        hideStartingOverlay();
        final result = await Dialogs.showDecisionDialog<bool>(
          context,
          content: 'Willst du wirklich das Spiel verlassen?',
        );
        if (result) {
          currentGameBloc.add(LeaveGame());
        }
        return Future(() => result);
      },
      child: BlocConsumer<CurrentGameBloc, CurrentGameState>(
        listener: (context, state) async {
          if (state is PlayerJoined && mounted) {
            showSimpleNotification(
              Text('${state.player?.name} ist dem Spiel beigetreten.'),
              foreground: Colors.white,
            );
          } else if (state is PlayerLeaved && mounted) {
            showSimpleNotification(
              Text('${state.player?.name} hat das Spiel verlassen.'),
              foreground: Colors.white,
            );
          } else if (state is CurrentGameStarting && mounted) {
            showStartingOverlay(context);
          } else if (state is CurrentGameFinished) {
            Navigator.of(context).pop();
          } else if (state is WaitForBingoCall) {
            panelController.close();
            setState(() {
              showCallBingoButton = true;
              isSuperBingo = state.isSuperBingo;
            });
            await Future.delayed(const Duration(seconds: 4), () {
              if (showCallBingoButton) {
                setState(() => showCallBingoButton = false);
                currentGameBloc.add(const DrawCard());
              }
            });
          } else {
            hideStartingOverlay();
          }
        },
        cubit: currentGameBloc,
        builder: (context, state) {
          String title, currentPlayerId;
          List<GameCard> playedCards, unplayedCards;
          List<Player> player;

          if (state is CurrentGameLoaded) {
            title = state.game.name;
            currentPlayerId = state.game.currentPlayerId;
            playedCards = state.game.playedCards;
            unplayedCards = state.game.unplayedCards;
            player = state.game.players;
          } else if (state is CurrentGameWaitingForPlayer) {
            title = state.game.name;
            currentPlayerId = state.game.currentPlayerId;
            playedCards = state.game.playedCards;
            unplayedCards = state.game.unplayedCards;
            player = state.game.players;
          } else {
            title = 'Aktuelles Spiel';
            currentPlayerId = '';
            playedCards = <GameCard>[
              GameCard(
                id: '1',
                color: CardColor.clover,
                number: CardNumber.five,
              ),
            ];
            unplayedCards = <GameCard>[
              GameCard(
                id: '1',
                color: CardColor.clover,
                number: CardNumber.five,
              ),
            ];
            player = <Player>[];
          }

          final baseChild = Stack(
            children: <Widget>[
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final innerConstraints = constraints * 0.8;

                    return ConstrainedBox(
                      constraints: innerConstraints,
                      child: AspectRatio(
                        aspectRatio: innerConstraints.maxHeight >=
                                innerConstraints.maxWidth
                            ? 0.675
                            : 2,
                        child: CustomPaint(
                          painter: VirtualTablePainter(),
                          child: SizedBox.expand(
                            child: Stack(
                              children: <Widget>[
                                Positioned.fill(
                                  child: PlayerAvatars(
                                    player: player,
                                    currentPlayerUid: currentPlayerId,
                                  ),
                                ),
                                Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      CardStack(
                                        type: CardStackType.unplayedCards,
                                        cards: unplayedCards,
                                        // cards: defaultCardDeck,
                                      ),
                                      SizedBox(
                                        width: innerConstraints.maxWidth * 0.1,
                                      ),
                                      CardStack(
                                        type: CardStackType.playedCards,
                                        cards: playedCards,
                                        // cards: defaultCardDeck,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // const CardHand(),

              // Positioned(
              //   bottom: MediaQuery.of(context).size.height / 3,
              //   right: 8,
              //   child: FloatingActionButton(
              //     backgroundColor: Colors.orange,
              //     onPressed: () {},
              //     child: Icon(Icons.flag),
              //   ),
              // ),
              if (state is CurrentGameWaitingForPlayer) ...[
                IgnorePointer(
                  child: SizedBox.expand(),
                ),
                _LobbyOverlay(
                  self: state.self,
                  game: state.game,
                ),
              ],
              if (state is CurrentGameLoaded && state.game.isCompleted) ...[
                _CompletedGameOverlay(
                  game: state.game,
                  self: state.self,
                ),
              ],
            ],
          );

          return ScreenTypeLayout.builder(
            mobile: (context) => LayoutBuilder(
              builder: (context, constraints) => SlidingUpPanel(
                controller: panelController,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                color: Theme.of(context).canvasColor,
                minHeight: state is CurrentGameLoaded && state.game.isRunning
                    ? constraints.maxHeight / 4
                    : 0,
                maxHeight: constraints.maxHeight - kToolbarHeight - 20,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                isDraggable:
                    true, // state is CurrentGameLoaded && state.game.isRunning,
                panelSnapping: false,
                panel: CardScrollView(),
                body: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.deepOrangeAccent,
                    title: Text(title),
                  ),
                  body: baseChild,
                  floatingActionButton: showCallBingoButton
                      ? FloatingActionButton.extended(
                          icon: Icon(Icons.volume_up),
                          label: Text(
                            'Rufe ${isSuperBingo ? 'SuperBingo' : 'Bingo'}',
                          ),
                          onPressed: () {
                            setState(() => showCallBingoButton = false);
                            context.read<InteractionBloc>().add(
                                  isSuperBingo ? CallSuperBingo() : CallBingo(),
                                );
                          },
                        )
                      : null,
                ),
              ),
            ),
            tablet: (context) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.deepOrangeAccent,
                title: Text(title),
              ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: baseChild,
                  ),
                  const Divider(),
                  SizedBox(
                    height: 200 + 32.0,
                    child: Builder(
                      builder: (context) {
                        if (state is CurrentGameLoaded) {
                          if (state.self.cards.isEmpty) {
                            if (state.self.finishPosition <= 0) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text(
                                      'Nur weil du deine Karten versteckst hast du das Spiel nicht gewonnen.',
                                    ),
                                    const SizedBox(height: 8),
                                    RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      onPressed: null,
                                      child: const Text(
                                        'Karten suchen...',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Du bist fertig. Warte bis alle ihre Karten abgelegt haben.',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                          } else {
                            return LayoutBuilder(
                              builder: (context, constraints) => Padding(
                                padding: EdgeInsets.fromLTRB(
                                  constraints.maxWidth / 4,
                                  0,
                                  constraints.maxWidth / 4,
                                  16,
                                ),
                                child: HorizontalCardList(
                                  cards: state.self.cards,
                                  cardHeight: constraints.maxHeight - 42,
                                  cardWidth: (constraints.maxHeight - 42) *
                                      (100 / 175),
                                ),
                              ),
                            );
                          }
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: showCallBingoButton
                  ? FloatingActionButton.extended(
                      icon: Icon(Icons.volume_up),
                      label: Text(
                        'Rufe ${isSuperBingo ? 'SuperBingo' : 'Bingo'}',
                      ),
                      onPressed: () {
                        setState(() => showCallBingoButton = false);
                        context.read<InteractionBloc>().add(
                              isSuperBingo ? CallSuperBingo() : CallBingo(),
                            );
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  void showStartingOverlay(BuildContext context) {
    startingOverlay = OverlayEntry(
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Material(
          color: Colors.black.withOpacity(0.25),
          child: const Loading(
            content: 'Das Spiel wird gestartet',
          ),
        ),
      ),
    );

    Overlay.of(context).insert(startingOverlay);
  }

  void hideStartingOverlay() {
    if (startingOverlay != null) {
      startingOverlay?.remove();
      startingOverlay = null;
    }
  }
}

class _CompletedGameOverlay extends StatelessWidget {
  final Player self;
  final Game game;

  const _CompletedGameOverlay({
    Key key,
    @required this.self,
    @required this.game,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 2,
        sigmaY: 2,
      ),
      child: SizedBox.expand(
        child: Center(
          child: Builder(
            builder: (context) {
              if (self.isHost) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Das Spiel ist vorbei.'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RaisedButton.icon(
                              onPressed: () {},
                              label: const Text('Neues Spiel starten'),
                              icon: const Icon(Icons.refresh),
                            ),
                            const SizedBox(width: 16),
                            RaisedButton.icon(
                              onPressed: () => context
                                  .read<CurrentGameBloc>()
                                  .add(EndGame()),
                              label: const Text('Spiel beenden'),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Das Spiel ist vorbei.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _LobbyOverlay extends StatelessWidget {
  const _LobbyOverlay({
    Key key,
    @required this.self,
    @required this.game,
  }) : super(key: key);

  final Player self;
  final Game game;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 2,
        sigmaY: 2,
      ),
      child: SizedBox.expand(
        child: Center(
          child: Builder(
            builder: (context) {
              if (self.isHost) {
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'Warten auf weitere Spieler...',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () async => IShareService().share(
                                game.link,
                              ),
                              child: const Text(
                                'Link teilen',
                              ),
                            ),
                            const SizedBox(width: 16),
                            RaisedButton(
                              onPressed: () {
                                context.read<CurrentGameBloc>().add(
                                      StartGame(
                                        gameId: game.gameID,
                                        self: self,
                                      ),
                                    );
                              },
                              child: const Text(
                                'Spiel starten',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const CircularProgressIndicator.adaptive(),
                        const SizedBox(height: 16),
                        Text(
                          'Warten auf weitere Spieler...',
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 24,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class VirtualTablePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..color = Colors.blueAccent;
    final borderPaint = Paint()..color = Colors.black.withOpacity(0.1);
    Path basePath, borderPath, upperPath;

    if (size.width >= size.height) {
      basePath = _buildHorizontalTableBaseShape(size);
      borderPath = _buildHorizontalTableBaseShape(
        Size(size.width * 0.95, size.height * 0.9),
      ).shift(
        Offset(size.width * 0.025, size.height * 0.05),
      );
      upperPath = _buildHorizontalTableBaseShape(
        Size(size.width * 0.925, size.height * 0.85),
      ).shift(
        Offset(size.width * 0.0375, size.height * 0.075),
      );
    } else {
      basePath = _buildVerticalTableBaseShape(size);
      borderPath = _buildVerticalTableBaseShape(
        Size(size.width * 0.9, size.height * 0.95),
      ).shift(
        Offset(size.width * 0.05, size.height * 0.025),
      );
      upperPath = _buildVerticalTableBaseShape(
        Size(size.width * 0.85, size.height * 0.925),
      ).shift(
        Offset(size.width * 0.075, size.height * 0.0375),
      );
    }

    canvas.drawPath(basePath, basePaint);
    canvas.drawPath(borderPath, borderPaint);
    canvas.drawPath(upperPath, basePaint);
  }

  Path _buildVerticalTableBaseShape(Size size) {
    final innerHeight = size.height * kTableInnerSizeFactor;
    final endsRadius = (size.height - innerHeight) / 2;

    return Path()
      ..addRect(
        Rect.fromLTWH(
          0,
          endsRadius,
          size.width,
          innerHeight,
        ),
      )
      ..arcTo(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          2 * endsRadius,
        ),
        0,
        270,
        true,
      )
      ..arcTo(
        Rect.fromLTWH(
          0,
          size.height - (2 * endsRadius),
          size.width,
          2 * endsRadius,
        ),
        0,
        270,
        true,
      );
  }

  Path _buildHorizontalTableBaseShape(Size size) {
    final innerWidth = size.width * kTableInnerSizeFactor;
    final endsRadius = (size.width - innerWidth) / 2;

    // debugPrint('========= Painter =========');
    // debugPrint('Size: $size');
    // debugPrint('InnerWidth: $innerWidth');
    // debugPrint('CalcWidth: ${innerWidth + 2 * endsRadius}');
    // debugPrint('========= Painter =========');

    return Path()
      ..addRect(
        Rect.fromLTWH(
          endsRadius,
          0,
          innerWidth,
          size.height,
        ),
      )
      ..arcTo(
        Rect.fromLTWH(
          0,
          0,
          2 * endsRadius,
          size.height,
        ),
        0,
        270,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(
          size.width - (2 * endsRadius),
          0,
          2 * endsRadius,
          size.height,
        ),
        -90,
        180,
        true,
      )
      ..close();
  }

  @override
  bool shouldRepaint(VirtualTablePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(VirtualTablePainter oldDelegate) => false;
}
