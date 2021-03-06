import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:superbingo/constants/enums.dart';
import 'package:superbingo/utils/card_utils.dart';
import 'package:superbingo/utils/configuration_utils.dart';
import 'package:superbingo/utils/list_utils.dart';
import 'package:superbingo/utils/ui_utils.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Utils tests ->', () {
    group('UI tils tests ->', () {
      group('getPositionCoordinates tests ->', () {
        const constraints = BoxConstraints.tightFor(width: 1920, height: 1080);

        test('1 player', () {
          final coordinates = getPositionCoordinates(0, 1, constraints);
          expect(coordinates.top, 0);
          expect(coordinates.left, 0);
          expect(coordinates.right, null);
          expect(coordinates.bottom, null);
        });

        test('2 player', () {
          final coordinates1 = getPositionCoordinates(0, 2, constraints);
          expect(coordinates1.top, null);
          expect(coordinates1.left, 0);
          expect(coordinates1.right, null);
          expect(coordinates1.bottom, null);

          final coordinates2 = getPositionCoordinates(1, 2, constraints);
          expect(coordinates2.top, null);
          expect(coordinates2.left, null);
          expect(coordinates2.right, 0);
          expect(coordinates2.bottom, null);
        });

        test('3 player', () {
          final coordinates1 = getPositionCoordinates(0, 3, constraints);
          expect(coordinates1.top, null);
          expect(coordinates1.left, 0);
          expect(coordinates1.right, null);
          expect(coordinates1.bottom, 0);

          final coordinates2 = getPositionCoordinates(1, 3, constraints);
          expect(coordinates2.top, null);
          expect(coordinates2.left, 0);
          expect(coordinates2.right, null);
          expect(coordinates2.bottom, null);

          final coordinates3 = getPositionCoordinates(2, 3, constraints);
          expect(coordinates3.top, null);
          expect(coordinates3.left, null);
          expect(coordinates3.right, 0);
          expect(coordinates3.bottom, null);
        });
        test('4 player', () {
          final coordinates1 = getPositionCoordinates(0, 4, constraints);
          expect(coordinates1.top, null);
          expect(coordinates1.left, 0);
          expect(coordinates1.right, null);
          expect(coordinates1.bottom, 0);

          final coordinates2 = getPositionCoordinates(1, 4, constraints);
          expect(coordinates2.top, null);
          expect(coordinates2.left, 0);
          expect(coordinates2.right, null);
          expect(coordinates2.bottom, null);

          final coordinates3 = getPositionCoordinates(2, 4, constraints);
          expect(coordinates3.top, null);
          expect(coordinates3.left, null);
          expect(coordinates3.right, 0);
          expect(coordinates3.bottom, null);

          final coordinates4 = getPositionCoordinates(3, 4, constraints);
          expect(coordinates4.top, null);
          expect(coordinates4.left, null);
          expect(coordinates4.right, 0);
          expect(coordinates4.bottom, 0);
        });
        test('5 player', () {
          final coordinates1 = getPositionCoordinates(0, 5, constraints);
          expect(coordinates1.top, null);
          expect(coordinates1.left, 0);
          expect(coordinates1.right, null);
          expect(coordinates1.bottom, 0);

          final coordinates2 = getPositionCoordinates(1, 5, constraints);
          expect(coordinates2.top, 143);
          expect(coordinates2.left, 0);
          expect(coordinates2.right, null);
          expect(coordinates2.bottom, null);

          final coordinates3 = getPositionCoordinates(2, 5, constraints);
          expect(coordinates3.top, null);
          expect(coordinates3.left, 0);
          expect(coordinates3.right, null);
          expect(coordinates3.bottom, null);

          final coordinates4 = getPositionCoordinates(3, 5, constraints);
          expect(coordinates4.top, null);
          expect(coordinates4.left, null);
          expect(coordinates4.right, 0);
          expect(coordinates4.bottom, null);

          final coordinates5 = getPositionCoordinates(4, 5, constraints);
          expect(coordinates5.top, 143);
          expect(coordinates5.left, null);
          expect(coordinates5.right, 0);
          expect(coordinates5.bottom, null);
        });
        test('6 player', () {
          final coordinates1 = getPositionCoordinates(0, 6, constraints);
          expect(coordinates1.top, null);
          expect(coordinates1.left, 0);
          expect(coordinates1.right, null);
          expect(coordinates1.bottom, 0);

          final coordinates2 = getPositionCoordinates(1, 6, constraints);
          expect(coordinates2.top, 143);
          expect(coordinates2.left, 0);
          expect(coordinates2.right, null);
          expect(coordinates2.bottom, null);

          final coordinates3 = getPositionCoordinates(2, 6, constraints);
          expect(coordinates3.top, null);
          expect(coordinates3.left, 0);
          expect(coordinates3.right, null);
          expect(coordinates3.bottom, null);

          final coordinates4 = getPositionCoordinates(3, 6, constraints);
          expect(coordinates4.top, null);
          expect(coordinates4.left, null);
          expect(coordinates4.right, 0);
          expect(coordinates4.bottom, null);

          final coordinates5 = getPositionCoordinates(4, 6, constraints);
          expect(coordinates5.top, 143);
          expect(coordinates5.left, null);
          expect(coordinates5.right, 0);
          expect(coordinates5.bottom, null);

          final coordinates6 = getPositionCoordinates(5, 6, constraints);
          expect(coordinates6.top, null);
          expect(coordinates6.left, null);
          expect(coordinates6.right, 0);
          expect(coordinates6.bottom, 0);
        });
      });
    });

    group('card utils tests ->', () {
      group('getIconByCardColor tests ->', () {
        test('CardColor.clover', () {
          final iconData = getIconByCardColor(CardColor.clover);

          expect(iconData, CupertinoIcons.suit_club_fill);
        });

        test('CardColor.heart', () {
          final iconData = getIconByCardColor(CardColor.heart);

          expect(iconData, CupertinoIcons.suit_heart_fill);
        });

        test('CardColor.diamond', () {
          final iconData = getIconByCardColor(CardColor.diamond);

          expect(iconData, CupertinoIcons.suit_diamond_fill);
        });

        test('CardColor.spade', () {
          final iconData = getIconByCardColor(CardColor.spade);

          expect(iconData, CupertinoIcons.suit_spade_fill);
        });
      });

      group('getColorByCardColor tests ->', () {
        test('CardColor.diamond', () {
          final color = getColorByCardColor(CardColor.diamond);

          expect(color.value, Colors.red.value);
        });

        test('CardColor.heart', () {
          final color = getColorByCardColor(CardColor.heart);

          expect(color.value, Colors.red.value);
        });

        test('CardColor.spade', () {
          final color = getColorByCardColor(CardColor.spade);

          expect(color.value, Colors.black.value);
        });

        test('CardColor.clover', () {
          final color = getColorByCardColor(CardColor.clover);

          expect(color.value, Colors.black.value);
        });
      });

      group('getTextByCardNumber tests ->', () {
        test('CardNumber.ace', () {
          final text = getTextByCardNumber(CardNumber.ace);

          expect(text, 'A');
        });

        test('CardNumber.king', () {
          final text = getTextByCardNumber(CardNumber.king);

          expect(text, 'K');
        });

        test('CardNumber.queen', () {
          final text = getTextByCardNumber(CardNumber.queen);

          expect(text, 'D');
        });

        test('CardNumber.jack', () {
          final text = getTextByCardNumber(CardNumber.jack);

          expect(text, 'B');
        });

        test('CardNumber.joker', () {
          final text = getTextByCardNumber(CardNumber.joker);

          expect(text, 'J');
        });

        test('CardNumber.nine', () {
          final text = getTextByCardNumber(CardNumber.nine);

          expect(text, '9');
        });

        test('CardNumber.eight', () {
          final text = getTextByCardNumber(CardNumber.eight);

          expect(text, '8');
        });

        test('CardNumber.seven', () {
          final text = getTextByCardNumber(CardNumber.seven);

          expect(text, '7');
        });

        test('CardNumber.six', () {
          final text = getTextByCardNumber(CardNumber.six);

          expect(text, '6');
        });

        test('CardNumber.five', () {
          final text = getTextByCardNumber(CardNumber.five);

          expect(text, '5');
        });
      });

      group('isNumberCard', () {
        test('number card', () {
          final isNumber = isNumberCard(CardNumber.eight);
          expect(isNumber, true);
        });

        test('not number card', () {
          final isNumber = isNumberCard(CardNumber.ace);
          expect(isNumber, false);
        });
      });
    });

    group('configuration utils tests ->', () {
      test('return "Tim"', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'playername': 'Tim',
        });

        final name = await getUsername();

        expect(name, 'Tim');
      });

      test('return "Timo"', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'playername': 'Timo',
        });

        final name = await getUsername();

        expect(name, 'Timo');
      });

      test('return "Jarred"', () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'playername': 'Jarred',
        });

        final name = await getUsername();

        expect(name, 'Jarred');
      });
    });

    group('list utils tests ->', () {
      group('even length', () {
        test('length 2', () {
          final middle = getMiddleIndex(generateList(2));

          expect(middle, 0);
        });

        test('length 20', () {
          final middle = getMiddleIndex(generateList(20));

          expect(middle, 10);
        });

        test('length 100', () {
          final middle = getMiddleIndex(generateList(100));

          expect(middle, 50);
        });

        test('length 1000', () {
          final middle = getMiddleIndex(generateList(1000));

          expect(middle, 500);
        });
      });

      group('odd length', () {
        test('length 3', () {
          final middle = getMiddleIndex(generateList(3));

          expect(middle, 1);
        });

        test('length 27', () {
          final middle = getMiddleIndex(generateList(27));

          expect(middle, 13);
        });

        test('length 137', () {
          final middle = getMiddleIndex(generateList(137));

          expect(middle, 68);
        });

        test('length 1159', () {
          final middle = getMiddleIndex(generateList(1159));

          expect(middle, 579);
        });
      });
    });
  });
}

Iterable generateList(int length) =>
    List<String>.generate(length, (length) => 'test: $length');
