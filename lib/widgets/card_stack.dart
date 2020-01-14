import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math.dart' show radians;

import '../bloc/blocs/current_game_bloc.dart';
import '../bloc/events/current_game_events.dart' as events;
import '../models/app_models/card.dart';
import 'play_card.dart';

enum CardStackType {
  /// Stapel der gespielten Karten
  playedCards,

  /// Nachziehstapel
  unplayedCards
}

/// {@template cardstack}
/// [CardStack] stellt einen Kartenstapel dar und fügt den Spielkarten, die nötigen visuellen
/// Effekte hinzu, damit der Kartenstapel realistisch aussieht.
/// {@endtemplate}
class CardStack extends StatefulWidget {
  /// Konfiguration, ob es sich um den Nachziehstapel oder um den Stapel der gelegten Karten handelt
  final CardStackType type;

  /// Spielkarten, die auf diesem Kartenstapel liegen
  final List<GameCard> cards;

  /// {@macro cardstack}
  const CardStack({
    Key key,
    @required this.type,
    @required this.cards,
  })  : assert(cards != null),
        assert(type != null),
        super(key: key);

  @override
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  List<Map<String, dynamic>> cards;

  @override
  void initState() {
    super.initState();
    buildVisualEffects();
  }

  @override
  void didUpdateWidget(CardStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards != widget.cards) {
      buildVisualEffects();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    buildVisualEffects();
  }

  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    return Container(
      child: Stack(
        fit: StackFit.loose,
        children: cards
            .map<Widget>(
              (c) => Transform(
                child: Transform.rotate(
                  child: PlayCard(
                    card: c['card'],
                    elevation: c['elevation'] as double,
                    isFlipped: widget.type == CardStackType.unplayedCards,
                    onCardTap: (card) {
                      if (widget.type == CardStackType.unplayedCards) {
                        currentGameBloc.add(events.DrawCard());
                      }
                    },
                    shouldPaint: c['index'] as int >= cards.length - 5,
                  ),
                  angle: c['angle'] as double,
                ),
                transform: Matrix4.identity()
                  ..translate(
                    c['translationX'] as double,
                    c['translationY'] as double,
                  ),
              ),
            )
            .toList(),
      ),
    );
  }

  void buildVisualEffects() {
    final rn = Random();
    cards = widget.cards.map<Map<String, dynamic>>(
      (c) {
        final index = widget.cards.indexOf(c);
        double translationY, translationX, elevation = 0.0, angle = 0.0;
        if (c == widget.cards.last) {
          angle = radians(0);
        } else {
          angle = 1.0 + rn.nextInt(10);
          angle = radians(angle);
          angle = index & 1 == 0 ? angle : -angle;
        }
        translationY = 1.0 + rn.nextInt(5);
        translationX = 1.0 + rn.nextInt(5);
        if (rn.nextDouble() < 0.5) {
          translationX = -translationX;
        }
        if (rn.nextDouble() < 0.5) {
          translationY = -translationY;
        }

        if (index > widget.cards.length - 10) {
          elevation = index - (widget.cards.length - 10.0);
        }

        return <String, dynamic>{
          'card': c,
          'index': index,
          'elevation': elevation,
          'angle': angle,
          'translationX': translationX,
          'translationY': translationY,
        };
      },
    ).toList();
  }
}
