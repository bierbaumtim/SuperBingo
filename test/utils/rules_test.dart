import 'package:flutter_test/flutter_test.dart';
import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/rules.dart';

void main() {
  group('Rules tests ->', () {
    group('isCardAllowed tests ->', () {
      test('Herz 8 auf Pik Bube', () {
        final result = Rules.isCardAllowed(
          GameCard(
            color: CardColor.spade,
            number: CardNumber.jack,
            id: '0',
          ),
          GameCard(
            color: CardColor.heart,
            number: CardNumber.eight,
            id: '1',
          ),
        );

        expect(result, isTrue);
      });
    });
  });
}
