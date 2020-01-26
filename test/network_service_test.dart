import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superbingo/constants/card_deck.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/models/app_models/game.dart';
import 'package:superbingo/models/app_models/player.dart';
import 'package:superbingo/services/network_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  group(
    'network service test',
    () {
      String gameid;
      final service = NetworkService(MockFirestoreInstance());

      Queue<GameCard> _generateCardStack(int decks) {
        final uuid = Uuid();
        var cardDecks = List<GameCard>.from(defaultCardDeck);
        for (var i = 0; i < decks - 1; i++) {
          cardDecks.addAll(defaultCardDeck);
        }
        cardDecks = cardDecks.map((c) => c.setId(uuid.v4())).toList();

        return Queue<GameCard>.from(cardDecks);
      }

      Game createGame() {
        final _self = Player(
          id: Uuid().v4(),
          name: 'Player1',
          cards: <GameCard>[],
          finishPosition: 0,
          isHost: true,
        );

        final game = Game(
          unplayedCardStack: _generateCardStack(2),
          playedCardStack: Queue<GameCard>(),
          players: <Player>[
            _self,
          ],
          isPublic: true,
          cardAmount: 2 * defaultCardDeck.length,
          maxPlayer: 6,
          name: 'Test',
          state: GameState.created,
        );

        return game;
      }

      setUp(() async {
        final game = createGame();
        final doc = await service.addGame(
          game,
        );
        gameid = doc.documentID;
        await service.updateGameData(
          <String, dynamic>{
            'id': doc.documentID,
          },
          doc.documentID,
        );
      });

      test('setupService', () async {
        await service.setupSubscription(gameid);
        final StreamSubscription<Game> sub =
            service.gameChangedStream.listen((game) => null);

        expect(sub, isA<StreamSubscription<Game>>());

        await sub.cancel();
      });
    },
    skip: true,
  );
}
