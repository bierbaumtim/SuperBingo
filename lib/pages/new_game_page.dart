import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:superbingo/blocs/game_bloc.dart';
import 'package:superbingo/models/app_models/game.dart';

class NewGamePage extends StatefulWidget {
  @override
  _NewGamePageState createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGamePage> {
  final formKey = GlobalKey<FormState>();
  bool isValid, isPublic, showStartGame, isDisabled;

  String name;
  int maxPlayer, cardAmount;

  FocusScopeNode _node = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    isValid = false;
    isPublic = false;
    showStartGame = false;
    isDisabled = false;
  }

  @override
  Widget build(BuildContext context) {
    final gameBloc = Provider.of<GameBloc>(context);

    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
        width: 1.5,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Neues Spiel'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: !isDisabled
                ? () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      setState(() => isValid = true);
                    }
                  }
                : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
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
                    validator: (text) => text.isNotEmpty ? null : 'Name is required',
                    onEditingComplete: () => _node.nextFocus(),
                    onSaved: (text) => name = text,
                    enabled: !isDisabled,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border,
                      labelText: 'Maximale Spieleranzahl (Default: 6)',
                      hintText: 'Gib eine Zahl zwischen 4-8 an',
                    ),
                    validator: (text) {
                      final parsedAmount = int.tryParse(text) ?? 0;
                      if (parsedAmount < 2 || parsedAmount > 6) {
                        return 'Es nur Zahlen zwischen 2 und 6 erlaubt';
                      } else if (text.isEmpty || parsedAmount > 2) {
                        return null;
                      } else {
                        return 'Es sind nur Zahlen erlaubt';
                      }
                    },
                    onSaved: (text) => maxPlayer = int.tryParse(text) ?? 6,
                    onEditingComplete: () => _node.nextFocus(),
                    enabled: !isDisabled,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border,
                      labelText: 'Anzahl der Karten',
                    ),
                    validator: (text) {
                      final parsedAmount = int.tryParse(text) ?? 0;
                      if (text.isEmpty || parsedAmount > 2) {
                        return null;
                      } else {
                        return 'Es sind nur Zahlen erlaubt';
                      }
                    },
                    onEditingComplete: () => _node.unfocus(),
                    onSaved: (text) => cardAmount = calculateCardAmount(text),
                    enabled: !isDisabled,
                  ),
                  SizedBox(height: 8),
                  CheckboxListTile(
                    title: Text('Öffentliches Spiel'),
                    value: isPublic,
                    onChanged: (value) => !isDisabled ? setState(() => isPublic = value) : null,
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
                        onPressed: () async {
                          final game = buildGame();
                          final success = await gameBloc.createGame(game);
                          setState(() {
                            showStartGame = success;
                            isValid = !success;
                            isDisabled = success;
                          });
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
                        onPressed: () async {
                          gameBloc.startGame();
                          Navigator.of(context).pushReplacementNamed('/game');
                        },
                      ),
                    ),
                    StreamBuilder<String>(
                      stream: gameBloc.gameLinkStream,
                      builder: (context, snapshot) {
                        final canShare = snapshot.hasData && snapshot.data.isNotEmpty;

                        return Padding(
                          padding: EdgeInsets.only(top: 25),
                          child: RaisedButton(
                            child: Text('Freunde einladen'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            onPressed: canShare
                                ? () async {
                                    Share.share(snapshot.data, subject: 'SuperBingo Spieleinladung');
                                  }
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
    );
  }

  Game buildGame() => Game(
        name: name,
        isPublic: isPublic,
        maxPlayer: maxPlayer,
        cardAmount: cardAmount,
      );

  int calculateCardAmount(String amountString) {
    int amount = int.tryParse(amountString);
    if (amount == null) {
      amount = ((maxPlayer % 4) + 1) * 32;
    }
    return amount;
  }
}
