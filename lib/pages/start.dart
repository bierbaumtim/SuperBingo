import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 75,
              left: 0,
              right: 0,
              child: Center(
                child: RaisedButton(
                  onPressed: () {},
                  child: const Text('Start game'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 36,
                  ),
                  textColor: Colors.white,
                  color: Colors.orange,
                  elevation: 6.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
