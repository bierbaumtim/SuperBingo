import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superbingo/blocs/info_bloc.dart';

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  String username;

  @override
  void initState() {
    super.initState();
    username = '';
  }

  @override
  Widget build(BuildContext context) {
    final infoBloc = Provider.of<InfoBloc>(context);

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
              decoration: InputDecoration(
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                labelText: 'Name',
                hintText: 'Gib den Spiel einen Namen',
              ),
              onChanged: (text) => username = text,
              onSubmitted: (text) => setState(() => username = text),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        label: Text('Spieler erstellen'),
        icon: Icon(Icons.arrow_forward_ios),
        onPressed: () async {
          if (username != null && username.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', username);
            infoBloc.firstStartCompleted();
            Navigator.pop(context);
          } else {
            showDialog(
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
      ),
    );
  }
}
