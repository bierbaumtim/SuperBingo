import 'package:flutter_test/flutter_test.dart';
import 'package:superbingo/utils/ui_utils.dart';

void main() {
  group('Utils tests', () {
    group('UI tils tests', () {
      group('getPositionCoordinates tests', () {
        test('1 player', () {
          final coordinates = getPositionCoordinates(0, 1, 350);
          expect(coordinates['top'], 0);
          expect(coordinates['left'], 0);
          expect(coordinates['right'], null);
          expect(coordinates['bottom'], null);
        });

        test('2 player', () {
          final coordinates1 = getPositionCoordinates(0, 2, 350);
          expect(coordinates1['top'], null);
          expect(coordinates1['left'], 0);
          expect(coordinates1['right'], null);
          expect(coordinates1['bottom'], null);

          final coordinates2 = getPositionCoordinates(1, 2, 350);
          expect(coordinates2['top'], null);
          expect(coordinates2['left'], null);
          expect(coordinates2['right'], 0);
          expect(coordinates2['bottom'], null);
        });

        test('3 player', () {
          final coordinates1 = getPositionCoordinates(0, 3, 350);
          expect(coordinates1['top'], null);
          expect(coordinates1['left'], 0);
          expect(coordinates1['right'], null);
          expect(coordinates1['bottom'], 0);

          final coordinates2 = getPositionCoordinates(1, 3, 350);
          expect(coordinates2['top'], null);
          expect(coordinates2['left'], 0);
          expect(coordinates2['right'], null);
          expect(coordinates2['bottom'], null);

          final coordinates3 = getPositionCoordinates(2, 3, 350);
          expect(coordinates3['top'], null);
          expect(coordinates3['left'], null);
          expect(coordinates3['right'], 0);
          expect(coordinates3['bottom'], null);
        });
      });
    });
  });
}
