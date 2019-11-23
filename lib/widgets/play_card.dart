import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superbingo/bloc/blocs/current_game_bloc.dart';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/card_utils.dart';
import 'package:superbingo/widgets/card_number_color.dart';
import 'package:superbingo/widgets/inner_card_icons.dart';
import 'package:superbingo/widgets/inner_card_image.dart';

import 'package:vector_math/vector_math.dart' show radians;

class PlayCard extends StatelessWidget {
  final GameCard card;
  final double height;
  final double width;
  final double angle;
  final double rotationAngle;
  final double elevation;
  final int index;
  final bool isActive;

  const PlayCard({
    Key key,
    this.card,
    this.angle,
    this.index,
    this.rotationAngle,
    this.height = 175,
    this.width = 100,
    this.elevation = 0,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);

    final cardWidget = GestureDetector(
      onTap: () {
        if (isActive) {
          currentGameBloc.playCard(card);
        }
      },
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white,
        child: SizedBox(
          height: height,
          width: width,
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
                  left: 28,
                  right: 28,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InnerCardIcons(
                        color: card.color,
                      ),
                      Transform.rotate(
                        angle: radians(180),
                        child: InnerCardIcons(
                          color: card.color,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isNumberCard(card.number))
                Positioned(
                  top: 20,
                  bottom: 20,
                  left: 28,
                  right: 28,
                  child: InnerCardImage(),
                ),
              Positioned(
                top: 16,
                left: 4,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                ),
              ),
              Positioned(
                top: 16,
                right: 4,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                ),
              ),
              Positioned(
                bottom: 16,
                left: 4,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  flip: true,
                ),
              ),
              Positioned(
                bottom: 16,
                right: 4,
                child: CardNumberColor(
                  color: card.color,
                  number: card.number,
                  flip: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (angle != null && rotationAngle != null) {
      final rad = radians(angle);
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
