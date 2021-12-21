import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../bloc/blocs/current_game_bloc.dart';
import '../bloc/blocs/interaction_bloc.dart';
import '../bloc/events/current_game_events.dart'
    show LeaveGame, DrawPenaltyCard, StartGame, EndGame;
import '../bloc/events/interaction_events.dart';
import '../bloc/states/current_game_states.dart';
import '../constants/enums.dart';
import '../models/app_models/card.dart';
import '../models/app_models/game.dart';
import '../models/app_models/player.dart';
import '../services/share_service/share_service_interface.dart';
import '../utils/card_utils.dart';
import '../utils/dialogs.dart';
import '../widgets/avatars/player_avatars.dart';
import '../widgets/game/card_stack.dart';
import '../widgets/game/horizontal_card_listview.dart';
import '../widgets/game/mobile_card_hand.dart';
import '../widgets/loading_widget.dart';
import '../widgets/virtual_table_painter.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  OverlayEntry? startingOverlay, timerOverlay, allowCardColorOverlay;
  late bool showCallBingoButton, isSuperBingo;

  @override
  void initState() {
    super.initState();
    showCallBingoButton = false;
    isSuperBingo = false;
  }

  @override
  void dispose() {
    hideStartingOverlay();
    hideTimerOverlay();
    hideAllowedCardColorOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        hideStartingOverlay();
        final result = await Dialogs.showDecisionDialog(
          context,
          content: 'Willst du wirklich das Spiel verlassen?',
        );
        if (result) {
          context.read<CurrentGameBloc>().add(LeaveGame());
        }
        return Future(() => result);
      },
      child: BlocConsumer<CurrentGameBloc, CurrentGameState>(
        listener: (context, state) async {
          if (state is CurrentGameStarting && mounted) {
            showStartingOverlay(context);
          } else if (state is CurrentGameFinished) {
            Navigator.of(context).pop();
          } else if (state is WaitForBingoCall) {
            setState(() {
              showCallBingoButton = true;
              isSuperBingo = state.isSuperBingo;
            });
            showTimerOverlay();
            await Future.delayed(const Duration(seconds: 4), () {
              if (showCallBingoButton) {
                setState(() => showCallBingoButton = false);
                context.read<CurrentGameBloc>().add(DrawPenaltyCard());
              }
            });
            hideTimerOverlay();
          } else if (state is UserChangedAllowedCardColor) {
            if (state.cardColor == null) {
              hideAllowedCardColorOverlay();
            } else {
              showAllowedCardColorOverlay(state.cardColor!);
            }
          } else {
            hideStartingOverlay();
          }
        },
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
                            ? 0.575
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                const IgnorePointer(
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
              builder: (context, constraints) => Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.deepOrangeAccent,
                  title: Text(title),
                ),
                body: Column(
                  children: <Widget>[
                    Expanded(child: baseChild),
                    _CardArea(
                      state: state,
                      showCallBingoButton: showCallBingoButton,
                      cardHand: (cards) => MobileCardHand(
                        cards: cards,
                      ),
                    ),
                  ],
                ),
                floatingActionButton: showCallBingoButton
                    ? FloatingActionButton.extended(
                        icon: const Icon(Icons.volume_up),
                        label: Text(
                          'Rufe ${isSuperBingo ? 'SuperBingo' : 'Bingo'}',
                        ),
                        onPressed: () {
                          setState(() => showCallBingoButton = false);
                          hideTimerOverlay();
                          context.read<InteractionBloc>().add(
                                isSuperBingo ? CallSuperBingo() : CallBingo(),
                              );
                        },
                      )
                    : null,
              ),
            ),
            tablet: (context) => Scaffold(
              appBar: AppBar(
                // backgroundColor: Colors.deepOrangeAccent,
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
                    child: _CardArea(
                      state: state,
                      showCallBingoButton: showCallBingoButton,
                      cardHand: (cards) => LayoutBuilder(
                        builder: (context, constraints) => Padding(
                          padding: getValueForScreenType<EdgeInsets>(
                            context: context,
                            mobile: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            tablet: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            desktop: EdgeInsets.fromLTRB(
                              constraints.maxWidth / 10,
                              0,
                              constraints.maxWidth / 10,
                              16,
                            ),
                          ),
                          child: HorizontalCardList(
                            cards: cards,
                            cardHeight: constraints.maxHeight - 42,
                            cardWidth:
                                (constraints.maxHeight - 42) * (100 / 175),
                            // canDrawCards: state.game.canDrawCards,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: showCallBingoButton
                  ? FloatingActionButton.extended(
                      icon: const Icon(Icons.volume_up),
                      label: Text(
                        'Rufe ${isSuperBingo ? 'SuperBingo' : 'Bingo'}',
                      ),
                      onPressed: () {
                        setState(() => showCallBingoButton = false);
                        hideTimerOverlay();
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

    Overlay.of(context)?.insert(startingOverlay!);
  }

  void hideStartingOverlay() {
    if (startingOverlay != null) {
      startingOverlay?.remove();
      startingOverlay = null;
    }
  }

  void showTimerOverlay({
    Duration duration = const Duration(seconds: 4),
  }) {
    timerOverlay = OverlayEntry(
      builder: (context) => Align(
        alignment: const Alignment(0.0, -0.865),
        child: Card(
          elevation: 4,
          color: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TimerText(
              duration: duration,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(timerOverlay!);
  }

  void hideTimerOverlay() {
    if (timerOverlay != null) {
      timerOverlay?.remove();
      timerOverlay = null;
    }
  }

  void showAllowedCardColorOverlay(CardColor color) {
    if (allowCardColorOverlay != null) {
      hideAllowedCardColorOverlay();
    }

    allowCardColorOverlay = OverlayEntry(
      builder: (context) => Align(
        alignment: const Alignment(0.0, -0.9),
        child: Card(
          elevation: 4,
          color: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  getIconByCardColor(color),
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '${color.toReadableString()} wurde sich gewünscht',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(allowCardColorOverlay!);
  }

  void hideAllowedCardColorOverlay() {
    if (allowCardColorOverlay != null) {
      allowCardColorOverlay?.remove();
      allowCardColorOverlay = null;
    }
  }
}

class TimerText extends StatefulWidget {
  const TimerText({
    Key? key,
    required this.duration,
  }) : super(key: key);

  final Duration duration;

  @override
  _TimerTextState createState() => _TimerTextState();
}

class _TimerTextState extends State<TimerText> {
  Timer? timer;
  late int remainingSeconds;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.duration.inSeconds;
    SchedulerBinding.instance!.addPostFrameCallback(
      (_) => timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (remainingSeconds > 0) {
            setState(() => remainingSeconds--);
          } else {
            timer?.cancel();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$remainingSeconds Seconds');
  }
}

class _CompletedGameOverlay extends StatelessWidget {
  final Player self;
  final Game game;

  const _CompletedGameOverlay({
    Key? key,
    required this.self,
    required this.game,
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
                            ElevatedButton.icon(
                              onPressed: () {},
                              label: const Text('Neues Spiel starten'),
                              icon: const Icon(Icons.refresh),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
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
                return const Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
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
    Key? key,
    required this.self,
    required this.game,
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
                            ElevatedButton(
                              onPressed: () async =>
                                  GetIt.I.get<IShareService>().share(
                                        game.link,
                                      ),
                              child: const Text(
                                'Link teilen',
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
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
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
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

class _CardArea extends StatelessWidget {
  final CurrentGameState state;
  final Widget Function(List<GameCard> cards) cardHand;
  final bool showCallBingoButton;

  const _CardArea({
    Key? key,
    required this.state,
    required this.cardHand,
    this.showCallBingoButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (state is CurrentGameLoaded) {
          if ((state as CurrentGameLoaded).self.cards.isEmpty) {
            if (showCallBingoButton) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Vergiss nicht Superbingo zu rufen!',
                  textAlign: TextAlign.center,
                ),
              );
            } else if ((state as CurrentGameLoaded).self.finishPosition <= 0) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Nur weil du deine Karten versteckst hast du das Spiel nicht gewonnen.',
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
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
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Du bist fertig. Warte bis alle ihre Karten abgelegt haben.',
                  textAlign: TextAlign.center,
                ),
              );
            }
          } else {
            return cardHand((state as CurrentGameLoaded).self.cards);
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
