import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/card.dart';

/// Ein komplettes Kartendeck, bestehend aus `heartCardDeck`,`spadeCardDeck`,`cloverCardDeck`,`diamondCardDeck`
final List<GameCard> defaultCardDeck =
    heartCardDeck + spadeCardDeck + cloverCardDeck + diamondCardDeck;

final List<GameCard> heartCardDeck = [
  GameCard(
    color: CardColor.heart,
    number: CardNumber.five,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.six,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.seven,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.eight,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.nine,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.jack,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.queen,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.king,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.ace,
  ),
];

final List<GameCard> spadeCardDeck = [
  GameCard(
    color: CardColor.spade,
    number: CardNumber.five,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.six,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.seven,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.eight,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.nine,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.jack,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.queen,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.king,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.ace,
  ),
];

final List<GameCard> cloverCardDeck = [
  GameCard(
    color: CardColor.clover,
    number: CardNumber.five,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.six,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.seven,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.eight,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.nine,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.jack,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.queen,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.king,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.ace,
  ),
];

final List<GameCard> diamondCardDeck = [
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.five,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.six,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.seven,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.eight,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.nine,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.jack,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.queen,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.king,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.ace,
  ),
];

final List<GameCard> joker = [];
