import '../models/app_models/card.dart';
import 'enums.dart';

/// Ein komplettes Kartendeck, bestehend aus
/// `heartCardDeck`,`spadeCardDeck`,`cloverCardDeck`,`diamondCardDeck`
final List<GameCard> defaultCardDeck =
    heartCardDeck + spadeCardDeck + cloverCardDeck + diamondCardDeck;

final List<GameCard> heartCardDeck = [
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.five,
  ),
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.six,
  ),
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.seven,
  ),
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.eight,
  ),
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.nine,
  ),
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.jack,
  ),
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.queen,
  ),
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.king,
  ),
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.ace,
  ),
];

final List<GameCard> spadeCardDeck = [
  GameCard(
    id: '',
    color: CardColor.spade,
    number: CardNumber.five,
  ),
  GameCard(
    id: '',
    color: CardColor.spade,
    number: CardNumber.six,
  ),
  GameCard(
    id: '',
    color: CardColor.spade,
    number: CardNumber.seven,
  ),
  GameCard(
    id: '',
    color: CardColor.spade,
    number: CardNumber.eight,
  ),
  GameCard(
    id: '',
    color: CardColor.spade,
    number: CardNumber.nine,
  ),
  GameCard(
    id: '',
    color: CardColor.spade,
    number: CardNumber.jack,
  ),
  GameCard(
    id: '',
    color: CardColor.spade,
    number: CardNumber.queen,
  ),
  GameCard(
    id: '',
    color: CardColor.spade,
    number: CardNumber.king,
  ),
  GameCard(
    id: '',
    color: CardColor.spade,
    number: CardNumber.ace,
  ),
];

final List<GameCard> cloverCardDeck = [
  GameCard(
    id: '',
    color: CardColor.clover,
    number: CardNumber.five,
  ),
  GameCard(
    id: '',
    color: CardColor.clover,
    number: CardNumber.six,
  ),
  GameCard(
    id: '',
    color: CardColor.clover,
    number: CardNumber.seven,
  ),
  GameCard(
    id: '',
    color: CardColor.clover,
    number: CardNumber.eight,
  ),
  GameCard(
    id: '',
    color: CardColor.clover,
    number: CardNumber.nine,
  ),
  GameCard(
    id: '',
    color: CardColor.clover,
    number: CardNumber.jack,
  ),
  GameCard(
    id: '',
    color: CardColor.clover,
    number: CardNumber.queen,
  ),
  GameCard(
    id: '',
    color: CardColor.clover,
    number: CardNumber.king,
  ),
  GameCard(
    id: '',
    color: CardColor.clover,
    number: CardNumber.ace,
  ),
];

final List<GameCard> diamondCardDeck = [
  GameCard(
    id: '',
    color: CardColor.diamond,
    number: CardNumber.five,
  ),
  GameCard(
    id: '',
    color: CardColor.diamond,
    number: CardNumber.six,
  ),
  GameCard(
    id: '',
    color: CardColor.diamond,
    number: CardNumber.seven,
  ),
  GameCard(
    id: '',
    color: CardColor.heart,
    number: CardNumber.eight,
  ),
  GameCard(
    id: '',
    color: CardColor.diamond,
    number: CardNumber.nine,
  ),
  GameCard(
    id: '',
    color: CardColor.diamond,
    number: CardNumber.jack,
  ),
  GameCard(
    id: '',
    color: CardColor.diamond,
    number: CardNumber.queen,
  ),
  GameCard(
    id: '',
    color: CardColor.diamond,
    number: CardNumber.king,
  ),
  GameCard(
    id: '',
    color: CardColor.diamond,
    number: CardNumber.ace,
  ),
];

final List<GameCard> joker = [];
