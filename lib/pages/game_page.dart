import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../bloc/blocs/current_game_bloc.dart';
import '../bloc/blocs/interaction_bloc.dart';
import '../bloc/events/current_game_events.dart';
import '../bloc/events/interaction_events.dart';
import '../bloc/states/current_game_states.dart';
import '../models/app_models/card.dart';
import '../utils/dialogs.dart';
import '../widgets/avatars/player_avatars.dart';
import '../widgets/card_scroll_view.dart';
import '../widgets/card_stack.dart';
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

    final height = MediaQuery.of(context).size.height;
    final playerAvatarBottomPosition = (height - kToolbarHeight) / 2.1;

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
          String title;
          List<GameCard> playedCards, unplayedCards;
          if (state is CurrentGameLoaded) {
            title = state.game.name;
            playedCards = state.game.playedCards;
            unplayedCards = state.game.unplayedCards;
          } else if (state is CurrentGameWaitingForPlayer) {
            title = state.game.name;
            playedCards = state.game.playedCards;
            unplayedCards = state.game.unplayedCards;
          } else {
            title = 'Aktuelles Spiel';
            playedCards = <GameCard>[];
            unplayedCards = <GameCard>[];
          }

          return LayoutBuilder(
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
              isDraggable: state is CurrentGameLoaded && state.game.isRunning,
              panelSnapping: false,
              panel: CardScrollView(),
              body: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.deepOrangeAccent,
                  title: Text(title),
                ),
                backgroundColor: Colors.deepOrangeAccent,
                body: SafeArea(
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 80,
                        left: 76,
                        right: 76,
                        bottom: playerAvatarBottomPosition,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: CardStack(
                                  type: CardStackType.unplayedCards,
                                  cards: unplayedCards,
                                  // cards: defaultCardDeck,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: CardStack(
                                  type: CardStackType.playedCards,
                                  cards: playedCards,
                                  // cards: defaultCardDeck,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const CardHand(),
                      const PlayerAvatars(),
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
                        if (state.self.isHost)
                          Positioned(
                            bottom: 2,
                            left: 8,
                            right: 8,
                            child: Center(
                              child: RaisedButton(
                                onPressed: () {
                                  currentGameBloc.add(StartGame(
                                    gameId: state.game.gameID,
                                    self: state.self,
                                  ));
                                },
                                child: const Text('Spiel starten'),
                              ),
                            ),
                          )
                        else
                          const Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Center(
                              child: Text('Warten auf weitere Spieler...'),
                            ),
                          ),
                      ],
                      if (state is CurrentGameLoaded &&
                          state.game.isCompleted) ...[
                        if (state.self.isHost)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: MediaQuery.of(context).size.height * 0.55,
                            bottom: 12,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Text('Das Spiel vorbei.'),
                                  const SizedBox(height: 12),
                                  RaisedButton.icon(
                                    onPressed: () {},
                                    label: const Text('Spiel neustarten'),
                                    icon: const Icon(Icons.refresh),
                                  ),
                                  const SizedBox(height: 12),
                                  RaisedButton.icon(
                                    onPressed: () =>
                                        currentGameBloc.add(EndGame()),
                                    label: const Text('Spiel beenden'),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.55,
                            left: 0,
                            right: 0,
                            bottom: 12,
                            child: const Center(
                              child: Text('Das Spiel vorbei.'),
                            ),
                          ),
                      ],
                      if (showCallBingoButton)
                        Positioned(
                          top: playerAvatarBottomPosition,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: RaisedButton(
                              onPressed: () {
                                setState(() {
                                  showCallBingoButton = false;
                                });
                                context.read<InteractionBloc>().add(
                                      isSuperBingo
                                          ? CallSuperBingo()
                                          : CallBingo(),
                                    );
                              },
                              child: Text(
                                'Rufe ${isSuperBingo ? 'SuperBingo' : 'Bingo'}',
                              ),
                            ),
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
