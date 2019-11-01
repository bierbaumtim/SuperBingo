import 'dart:math';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:superbingo/bloc/blocs/current_game_bloc.dart';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/card_utils.dart';
import 'package:superbingo/widgets/card_number_color.dart';
import 'package:superbingo/widgets/inner_card_icons.dart';
import 'package:superbingo/widgets/inner_card_image.dart';

import 'package:vector_math/vector_math.dart' show radians;

class SmallPlayCard extends StatelessWidget {
  final GameCard card;
  final double angle;
  final double rotationAngle;
  final int index;

  SmallPlayCard({
    Key key,
    @required this.card,
    this.angle,
    this.rotationAngle,
    this.index = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentGameBloc = Provider.of<CurrentGameBloc>(context);

    final cardWidget = Container(
      constraints: BoxConstraints(maxHeight: 175, maxWidth: 100),
      height: 175,
      width: 100,
      child: Card(
        elevation: (index + 1).toDouble(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white,
        child: GestureDetector(
          onTap: () async {
            final message = await currentGameBloc.playCard(card);
            if (message.isNotEmpty) {
              showSimpleNotification(
                Text(message),
                elevation: 4,
                foreground: Colors.white,
              );
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: <Widget>[
              if (!isNumberCard(card.number))
                Positioned(
                  top: 10,
                  right: 14,
                  left: 14,
                  bottom: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
              if (isNumberCard(card.number))
                Positioned(
                  top: 20,
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InnerCardIcons(
                        color: card.color,
                        isSmall: true,
                      ),
                      Transform.rotate(
                        angle: radians(180),
                        child: InnerCardIcons(
                          color: card.color,
                          isSmall: true,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isNumberCard(card.number))
                Positioned(
                  top: 20,
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: InnerCardImage(),
                ),
              Positioned(
                top: 16,
                left: 10,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                ),
              ),
              Positioned(
                top: 16,
                right: 10,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                ),
              ),
              Positioned(
                bottom: 16,
                left: 10,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                  flip: true,
                ),
              ),
              Positioned(
                bottom: 16,
                right: 10,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  isSmall: true,
                  flip: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (angle != null && rotationAngle != null) {
      final double rad = radians(angle);

      return Transform(
        transform: Matrix4.identity()
          ..translate(
            100 * cos(rad),
            (100 * sin(rad)) + 25,
          ),
        child: Transform.rotate(
          angle: radians(rotationAngle),
          child: cardWidget,
        ),
      );
    } else {
      return cardWidget;
    }
  }
}
