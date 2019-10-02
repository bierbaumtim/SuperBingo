import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Dialogs {
  static Future<T> showInformationDialog<T>(BuildContext context, {String title = 'Hinweis', String content = ''}) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          RaisedButton(
            color: Colors.deepOrange,
            child: Text(
              'Ok',
              style: Theme.of(context).textTheme.button.copyWith(
                    color: Colors.white,
                  ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
