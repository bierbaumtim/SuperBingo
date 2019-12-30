import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:superbingo/bloc/events/game_events.dart';
import 'package:superbingo/bloc/blocs/game_configuration_bloc.dart';
import 'package:superbingo/bloc/states/game_states.dart';
import 'package:superbingo/utils/dialogs.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';
import 'package:supercharged/supercharged.dart';

class NewGamePage extends StatefulWidget {
  @override
  _NewGamePageState createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGamePage> {
  final _formKey = GlobalKey<FormState>();
  final FocusScopeNode _node = FocusScopeNode();
  TextEditingController _playerAmountController, _cardDecksAmountController;
  bool isValid, isPublic, showStartGame, isDisabled;
  OverlayEntry _gameCreationOverlay;

  String name;
  int maxPlayer, cardAmount;

  @override
  void initState() {
    super.initState();
    isValid = false;
    isPublic = false;
    showStartGame = false;
    isDisabled = false;

    _playerAmountController = TextEditingController(text: '6');
    _cardDecksAmountController = TextEditingController(text: '2');
  }

  @override
  void dispose() {
    hideGameCreationOverlay();
    _playerAmountController?.dispose();
    _cardDecksAmountController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameBloc = BlocProvider.of<GameConfigurationBloc>(context);

    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
        width: 1.5,
      ),
    );

    return BlocListener<GameConfigurationBloc, GameConfigurationState>(
      listener: (context, state) async {
        if (state is GameCreating) {
          showGameCreationOverlay(context);
        } else if (state is GameCreated) {
          hideGameCreationOverlay();
          // Navigator.of(context).pushNamed('/game');
          setState(() {
            showStartGame = true;
            isValid = false;
            isDisabled = true;
          });
        } else if (state is GameCreationFailed) {
          hideGameCreationOverlay();
          await Dialogs.showInformationDialog<void>(
            context,
            title: 'Fehler',
            content: state.error,
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          if (showStartGame) {
            final result = await Dialogs.showDecisionDialog(
              context,
              content:
                  'Wenn du diese Seite jetzt verlässt, wird dein grade erstelltes Spiel gelöscht. '
                  'Möchtest du wirklich dein Spiel löschen ?',
            );
            if (result) {
              gameBloc.add(DeleteConfiguredGame());
            }
          }
          return Future(() => true);
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text('Neues Spiel'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.check),
                onPressed: !isDisabled
                    ? () {
                        _node.unfocus();
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          setState(() => isValid = true);
                        }
                      }
                    : null,
              ),
            ],
          ),
          body: GestureDetector(
            onTap: _node.unfocus,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Form(
                key: _formKey,
                child: FocusScope(
                  node: _node,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border,
                          labelText: 'Name',
                          hintText: 'Gib den Spiel einen Namen',
                        ),
                        validator: (text) => text.isNotEmpty
                            ? null
                            : 'Bitte gib den Namen des Spiels ein',
                        onEditingComplete: _node.nextFocus,
                        onSaved: (text) => name = text,
                        enabled: !isDisabled,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _playerAmountController,
                        decoration: InputDecoration(
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border,
                          labelText: 'Maximale Spieleranzahl (Default: 6)',
                          hintText: 'Gib eine Zahl zwischen 4-8 an',
                        ),
                        validator: (text) {
                          final parsedAmount = text.toInt() ?? 0;
                          if (text.isEmpty || parsedAmount > 2) {
                            return null;
                          } else if (parsedAmount < 2 || parsedAmount > 6) {
                            return 'Es nur Zahlen zwischen 2 und 6 erlaubt';
                          } else {
                            return 'Es sind nur Zahlen erlaubt';
                          }
                        },
                        onSaved: (text) => maxPlayer = text.toInt() ?? 6,
                        onEditingComplete: _node.nextFocus,
                        enabled: !isDisabled,
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _cardDecksAmountController,
                        decoration: InputDecoration(
                          border: border,
                          enabledBorder: border,
                          focusedBorder: border,
                          labelText: 'Anzahl der Kartendecks',
                        ),
                        validator: (text) {
                          final parsedAmount = text.toInt() ?? 0;
                          if (text.isEmpty || parsedAmount > 0) {
                            return null;
                          } else {
                            return 'Es sind nur Zahlen erlaubt';
                          }
                        },
                        onEditingComplete: _node.unfocus,
                        onSaved: (text) => cardAmount = text.toInt() ?? 1,
                        enabled: !isDisabled,
                      ),
                      SizedBox(height: 8),
                      CheckboxListTile(
                        title: Text('Öffentliches Spiel'),
                        value: isPublic,
                        onChanged: (value) => !isDisabled
                            ? setState(() => isPublic = value)
                            : null,
                        activeColor: Colors.deepOrange,
                      ),
                      if (isValid)
                        Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: RaisedButton(
                            child: Text('Spiel erstellen'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            onPressed: () {
                              gameBloc.add(CreateGame(
                                isPublic: isPublic,
                                maxPlayer: maxPlayer,
                                name: name,
                                decksAmount: cardAmount,
                              ));
                            },
                          ),
                        ),
                      if (showStartGame && !isValid) ...[
                        Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: RaisedButton(
                            child: Text('Spiel starten'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed('/game'),
                          ),
                        ),
                        StreamBuilder<String>(
                          stream: gameBloc.gameLinkStream,
                          builder: (context, snapshot) {
                            final canShare =
                                snapshot.hasData && snapshot.data.isNotEmpty;

                            return Padding(
                              padding: EdgeInsets.only(top: 25),
                              child: RaisedButton(
                                child: Text('Freunde einladen'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                onPressed: canShare
                                    ? () async => await Share.share(
                                          snapshot.data,
                                          subject: 'SuperBingo Spieleinladung',
                                        )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showGameCreationOverlay(BuildContext context) {
    _gameCreationOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: <Widget>[
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),
          Center(
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_gameCreationOverlay);
  }

  void hideGameCreationOverlay() {
    if (_gameCreationOverlay != null) {
      _gameCreationOverlay.remove();
      _gameCreationOverlay = null;
    }
  }
}
