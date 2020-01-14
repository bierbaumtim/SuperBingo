import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs/info_bloc.dart';
import '../bloc/events/info_events.dart';
import '../bloc/states/info_states.dart';

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  String username;
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    username = '';
    controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final infoBloc = BlocProvider.of<InfoBloc>(context);
    final username = infoBloc.state is InfosLoaded
        ? (infoBloc.state as InfosLoaded).playerName
        : '';
    if (controller.text.isEmpty) {
      controller.text = username;
      this.username = username;
    }
  }

  @override
  Widget build(BuildContext context) {
    final infoBloc = BlocProvider.of<InfoBloc>(context);

    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
        width: 1.5,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Neuer Spieler'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                labelText: 'Name',
              ),
              onChanged: (text) => username = text,
              onSubmitted: (text) => setState(() => username = text),
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<InfoBloc, InfoState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            backgroundColor: Colors.deepOrange,
            label: Text(
              state is InfosLoaded ? 'Name ändern' : 'Spieler erstellen',
            ),
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () async {
              if (username != null && username.isNotEmpty) {
                if (state is FirstStart) {
                  infoBloc.add(CompleteFirstStartConfiguration(username));
                } else {
                  infoBloc.add(SetPlayerName(username));
                  Navigator.pop(context);
                }
              } else {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Hinweis'),
                    content: Text('Der Benutzername darf nicht leer sein.'),
                    actions: <Widget>[
                      RaisedButton(
                        color: Colors.deepOrange,
                        child: Text(
                          'Ok',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
