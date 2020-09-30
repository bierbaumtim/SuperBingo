import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firedart/firedart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service/information_storage.dart';
import '../events/info_events.dart';
import '../states/info_states.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  final FirebaseAuth auth;

  InfoBloc(this.auth) : super(InfosEmpty()) {
    add(LoadInfos());
  }

  @override
  Stream<InfoState> mapEventToState(InfoEvent event) async* {
    if (event is LoadInfos) {
      yield* _mapLoadInfosToState(event);
    } else if (event is CompleteFirstStartConfiguration) {
      yield* _mapCompleteFirstStartConfigurationToState(event);
    } else if (event is SetPlayerName) {
      yield* _mapSetPlayerNameToState(event);
    }
  }

  Stream<InfoState> _mapLoadInfosToState(LoadInfos event) async* {
    yield InfosLoading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final firstStart = prefs.getBool('firststart') ?? true;
      if (firstStart) {
        await prefs.setInt('starttime', DateTime.now().millisecondsSinceEpoch);
        yield FirstStart();
      } else {
        final playerName = prefs.getString('playername') ?? '';
        await _loginUserAnonymous();
        final playerId = await userUid;
        InformationStorage.instance.playerId = playerId;
        yield InfosLoaded(
          playerName: playerName,
          playerId: playerId,
        );
      }
    } on dynamic catch (e, s) {
      await Crashlytics.instance.recordError(e, s);

      yield InfosEmpty();
    }
  }

  Stream<InfoState> _mapCompleteFirstStartConfigurationToState(
      CompleteFirstStartConfiguration event) async* {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firststart', false);
    await _loginUserAnonymous(
      forceLogin: true,
    );
    add(SetPlayerName(event.playerName));
  }

  Stream<InfoState> _mapSetPlayerNameToState(SetPlayerName event) async* {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playername', event.playerName);
    final playerId = await userUid;
    yield InfosLoaded(
      playerName: event.playerName,
      playerId: playerId,
    );
  }

  Future<void> _loginUserAnonymous({bool forceLogin = false}) async {
    if (forceLogin || (await auth.getUser()) != null) {
      await auth.signInAnonymously();
    }
  }

  Future<String> get userUid async => (await auth.getUser())?.id;
}
