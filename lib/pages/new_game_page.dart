import 'package:flutter/material.dart';

class NewGamePage extends StatefulWidget {
  @override
  _NewGamePageState createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGamePage> {
  final formKey = GlobalKey<FormState>();
  bool _isValid;

  @override
  void initState() {
    super.initState();
    _isValid = false;
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
        width: 1.5,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('New Game'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              setState(() {
                _isValid = formKey.currentState.validate();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                    labelText: 'Name',
                  ),
                  validator: (text) => text.isNotEmpty ? null : 'Name is required',
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                  validator: (text) => text.isNotEmpty ? null : 'Name is required',
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                  validator: (text) => text.isNotEmpty ? null : 'Name is required',
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                  validator: (text) => text.isNotEmpty ? null : 'Name is required',
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                  validator: (text) => text.isNotEmpty ? null : 'Name is required',
                ),
                if (_isValid)
                  Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: RaisedButton(
                      child: Text('Create Game'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      onPressed: () {},
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
