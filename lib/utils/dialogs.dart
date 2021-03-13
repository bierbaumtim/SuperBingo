import 'package:flutter/material.dart';

/// Klasse mit static Methoden verschiedener Dialogs
class Dialogs {
  /// Einfacher Dialog, um Informationen dem Nutzer anzuzeigen.
  ///
  /// `title` - Titel für den Dialog(Standard - Hinweis)
  /// `content` - Information für den Dialog
  static Future<T?> showInformationDialog<T>(
    BuildContext context, {
    String title = 'Hinweis',
    String content = '',
  }) {
    return showDialog<T?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.deepOrange,
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Ok',
              style: Theme.of(context).textTheme.button!.copyWith(
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
  static Future<bool> showDecisionDialog(
    BuildContext context, {
    String title = 'Hinweis',
    String content = '',
    String noText = 'Nein',
    String yesText = 'Ja',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              yesText,
              style: Theme.of(context).textTheme.button!.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.deepOrange,
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              noText,
              style: Theme.of(context).textTheme.button!.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
