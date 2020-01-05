import 'package:flutter/material.dart';

import 'package:superbingo/constants/enums.dart';

import 'package:community_material_icon/community_material_icon.dart';

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
    final selectedColor = Colors.deepOrangeAccent;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('Welche Farbe wünschst du dir ?'),
                ),
                RadioListTile(
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: CardColor.clover,
                  groupValue: color,
                  title: Text('Kreuz'),
                  secondary: Icon(CommunityMaterialIcons.cards_club),
                  onChanged: (value) => setState(() => color = value),
                  activeColor: selectedColor,
                ),
                RadioListTile(
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: CardColor.spade,
                  groupValue: color,
                  title: Text('Pik'),
                  secondary: Icon(CommunityMaterialIcons.cards_spade),
                  onChanged: (value) => setState(() => color = value),
                  activeColor: selectedColor,
                ),
                RadioListTile(
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: CardColor.heart,
                  groupValue: color,
                  title: Text('Herz'),
                  secondary: Icon(CommunityMaterialIcons.cards_heart),
                  onChanged: (value) => setState(() => color = value),
                  activeColor: selectedColor,
                ),
                RadioListTile(
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: CardColor.diamond,
                  groupValue: color,
                  title: Text('Karo'),
                  secondary: Icon(CommunityMaterialIcons.cards_diamond),
                  onChanged: (value) => setState(() => color = value),
                  activeColor: selectedColor,
                ),
                SizedBox(height: 24),
                RaisedButton(
                  child: Text('Wünschen'),
                  onPressed: () => Navigator.of(context).pop(color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
