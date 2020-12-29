import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String content;
  final EdgeInsets padding;

  const Loading({
    Key key,
    this.content = 'Laden',
    this.padding = const EdgeInsets.only(top: 8),
  })  : assert(content != null),
        assert(padding != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CupertinoActivityIndicator(),
              const SizedBox(width: 8),
              Text(content),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator.adaptive(),
          Padding(
            padding: padding,
            child: Material(
              color: Colors.transparent,
              child: Text(
                content,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  // fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
