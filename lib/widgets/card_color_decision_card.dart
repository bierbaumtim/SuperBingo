import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../constants/enums.dart';

class CardColorDecisionCard extends StatefulWidget {
  const CardColorDecisionCard({
    Key key,
  }) : super(key: key);

  @override
  _CardColorDecisionCardState createState() => _CardColorDecisionCardState();
}

class _CardColorDecisionCardState extends State<CardColorDecisionCard> {
  CardColor color;

  @override
  void initState() {
    super.initState();
    color = CardColor.clover;
  }

  @override
  Widget build(BuildContext context) {
    const selectedColor = Colors.deepOrangeAccent;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const ListTile(
                  title: Text('Welche Farbe wünschst du dir ?'),
                ),
                RadioListTile<CardColor>(
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: CardColor.clover,
                  groupValue: color,
                  title: const Text('Kreuz'),
                  secondary: const Icon(CupertinoIcons.suit_club_fill),
                  onChanged: (value) => setState(() => color = value),
                  activeColor: selectedColor,
                ),
                RadioListTile<CardColor>(
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: CardColor.spade,
                  groupValue: color,
                  title: const Text('Pik'),
                  secondary: const Icon(CupertinoIcons.suit_spade_fill),
                  onChanged: (value) => setState(() => color = value),
                  activeColor: selectedColor,
                ),
                RadioListTile<CardColor>(
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: CardColor.heart,
                  groupValue: color,
                  title: const Text('Herz'),
                  secondary: const Icon(CupertinoIcons.suit_heart_fill),
                  onChanged: (value) => setState(() => color = value),
                  activeColor: selectedColor,
                ),
                RadioListTile<CardColor>(
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: CardColor.diamond,
                  groupValue: color,
                  title: const Text('Karo'),
                  secondary: const Icon(CupertinoIcons.suit_diamond_fill),
                  onChanged: (value) => setState(() => color = value),
                  activeColor: selectedColor,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(color),
                  child: const Text('Wünschen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
