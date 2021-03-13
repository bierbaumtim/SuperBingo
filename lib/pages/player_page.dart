import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs/info_bloc.dart';
import '../bloc/events/info_events.dart';
import '../bloc/states/info_states.dart';
import '../utils/dialogs.dart';

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late String username;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    username = '';
    controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final infoBloc = context.read<InfoBloc>();
    final username = infoBloc.state is InfosLoaded
        ? (infoBloc.state as InfosLoaded).playerName
        : '';
    if (controller.text.isEmpty) {
      controller.text = username;
      this.username = username;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
        width: 1.5,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuer Spieler'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        label: const Text('Spieler erstellen'),
        icon: const Icon(Icons.arrow_forward_ios),
        onPressed: () async {
          if (username.isNotEmpty) {
            context.read<InfoBloc>().add(SetPlayerName(username));
            Navigator.of(context).pop(username);
          } else {
            await Dialogs.showInformationDialog(
              context,
              title: 'Hinweis',
              content: 'Der Benutzername darf nicht leer sein.',
            );
          }
        },
      ),
    );
  }
}
