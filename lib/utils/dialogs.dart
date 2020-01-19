import 'package:flutter/material.dart';

/// Klasse mit static Methoden verschiedener Dialogs
class Dialogs {
  /// Einfacher Dialog, um Informationen dem Nutzer anzuzeigen.
  ///
  /// `title` - Titel für den Dialog(Standard - Hinweis)
  /// `content` - Information für den Dialog
  static Future<T> showInformationDialog<T>(BuildContext context,
      {String title = 'Hinweis', String content = ''}) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          RaisedButton(
            color: Colors.deepOrange,
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Ok',
              style: Theme.of(context).textTheme.button.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog, um eine Entscheidung des Nutzers zu überprüfen bzw. abzufragen.
  ///
  /// `title` - Titel für den Dialog(Standard - Hinweis)
  /// `content` - Information für den Dialog
  /// `noText` - Text für den Nein-Button
  /// `yesText` - Text für den Ja-Button
  static Future<bool> showDecisionDialog<bool>(
    BuildContext context, {
    String title = 'Hinweis',
    String content = '',
    String noText = 'Nein',
    String yesText = 'Ja',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              yesText ?? 'Ja',
              style: Theme.of(context).textTheme.button.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          RaisedButton(
            color: Colors.deepOrange,
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              noText ?? 'Nein',
              style: Theme.of(context).textTheme.button.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
