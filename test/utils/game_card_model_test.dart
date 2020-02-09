import 'package:flutter_test/flutter_test.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/card.dart';

void main() {
  group('GameCard tests ->', () {
    group('constructor tests ->', () {
      test('give null for all parameters', () {
        // ignore: missing_required_param
        final card = GameCard();

        expect(card, isA<GameCard>());
        expect(card.id, isNull);
        expect(card.color, isNull);
        expect(card.number, isNull);
        expect(card.rule, isNull);
        expect(
          card.props,
          [null, null, null, null],
        );
      });

      test('no special rule', () {
        final card = GameCard(
          id: 'd4s9-6g',
          color: CardColor.diamond,
          number: CardNumber.five,
        );

        expect(card, isA<GameCard>());
        expect(card.id, 'd4s9-6g');
        expect(card.color, CardColor.diamond);
        expect(card.number, CardNumber.five);
        expect(card.rule, isNull);
        expect(
          card.props,
          [null, CardColor.diamond, CardNumber.five, 'd4s9-6g'],
        );
      });

      test('with special rule', () {
        final card = GameCard(
          id: 'd4s9-6g',
          color: CardColor.diamond,
          number: CardNumber.seven,
        );

        expect(card, isA<GameCard>());
        expect(card.id, 'd4s9-6g');
        expect(card.color, CardColor.diamond);
        expect(card.number, CardNumber.seven);
        expect(card.rule, SpecialRule.plusTwo);
        expect(
          card.props,
          [SpecialRule.plusTwo, CardColor.diamond, CardNumber.seven, 'd4s9-6g'],
        );
      });
    });

    group('model functions tests ->', () {
      group('ruleFromNumber tests ->', () {
        test('SpecialRule.skip', () {
          final rule = GameCard.ruleFromNumber(CardNumber.eight);
          expect(rule, isA<SpecialRule>());
          expect(rule, equals(SpecialRule.skip));
        });

        test('SpecialRule.reverse', () {
          final rule = GameCard.ruleFromNumber(CardNumber.nine);
          expect(rule, isA<SpecialRule>());
          expect(rule, equals(SpecialRule.reverse));
        });

        test('SpecialRule.joker', () {
          final rule = GameCard.ruleFromNumber(CardNumber.jack);
          expect(rule, isA<SpecialRule>());
          expect(rule, equals(SpecialRule.joker));
        });

        test('SpecialRule.joker', () {
          final rule = GameCard.ruleFromNumber(CardNumber.joker);
          expect(rule, isA<SpecialRule>());
          expect(rule, equals(SpecialRule.joker));
        });

        test('SpecialRule.plusTwo', () {
          final rule = GameCard.ruleFromNumber(CardNumber.seven);
          expect(rule, isA<SpecialRule>());
          expect(rule, equals(SpecialRule.plusTwo));
        });

        test('no SpecialRule', () {
          final rule = GameCard.ruleFromNumber(CardNumber.six);
          expect(rule, isNull);
        });
      });

      test('setId', () {
        var card = GameCard(
          color: CardColor.clover,
          number: CardNumber.queen,
        );

        expect(card, isA<GameCard>());
        expect(card.id, isNull);
        expect(card.color, equals(CardColor.clover));
        expect(card.number, equals(CardNumber.queen));
        expect(card.rule, isNull);

        card = card.setId('test id');

        expect(card, isA<GameCard>());
        expect(card.id, 'test id');
        expect(card.color, equals(CardColor.clover));
        expect(card.number, equals(CardNumber.queen));
        expect(card.rule, isNull);
      });

      test('toString', () {
        final card = GameCard(
          color: CardColor.clover,
          number: CardNumber.queen,
          id: 'toString id',
        );

        expect(
          card.toString(),
          equals(
            'GameCard{ id: toString id, color: CardColor.clover, number: CardNumber.queen, rule: null }',
          ),
        );
      });
    });

    group('json tests ->', () {
      test('json encoding', () {
        final card = GameCard(
          color: CardColor.heart,
          number: CardNumber.nine,
          id: 'toJson id',
        );

        final json = card.toJson();

        expect(
          json,
          equals(
            <String, dynamic>{
              'id': 'toJson id',
              'color': 'heart',
              'number': 'nine',
            },
          ),
        );
      });

      test('json decoding', () {
        final card = GameCard.fromJson(
          <String, dynamic>{
            'id': 'toJson id',
            'color': 'heart',
            'number': 'nine',
          },
        );

        expect(card, isA<GameCard>());
        expect(card.id, equals('toJson id'));
        expect(card.color, equals(CardColor.heart));
        expect(card.number, equals(CardNumber.nine));
        expect(card.rule, equals(SpecialRule.reverse));
      });
    });
  });
}
