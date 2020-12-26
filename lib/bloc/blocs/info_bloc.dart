import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service/auth_service_interface.dart';
import '../../services/information_storage.dart';
import '../../services/log_service.dart';
import '../events/info_events.dart';
import '../states/info_states.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  final IAuthService auth;

  InfoBloc(this.auth) : super(InfosEmpty()) {
    add(LoadInfos());
  }

  @override
  Stream<InfoState> mapEventToState(InfoEvent event) async* {
    if (event is LoadInfos) {
      yield* _mapLoadInfosToState(event);
    } else if (event is SetPlayerName) {
      yield* _mapSetPlayerNameToState(event);
    }
  }

  Stream<InfoState> _mapLoadInfosToState(LoadInfos event) async* {
    yield InfosLoading();
    try {
      final prefs = await SharedPreferences.getInstance();

      final playerName = prefs.getString('playername') ?? '';
      await _loginUserAnonymous(forceLogin: true);
      final playerId = await userUid;
      InformationStorage.instance.playerId = playerId;
      if (playerId != null) {
        yield InfosLoaded(
          playerName: playerName,
          playerId: playerId,
        );
      } else {
        yield InfosEmpty();
      }
    } on dynamic catch (e, s) {
      await LogService.instance.recordError(e, s);

      yield InfosEmpty();
    }
  }

  Stream<InfoState> _mapSetPlayerNameToState(SetPlayerName event) async* {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playername', event.playerName);

    if (InformationStorage.instance.playerId == null) {
      await _loginUserAnonymous(forceLogin: true);
    }
    final playerId = await userUid;

    yield InfosLoaded(
      playerName: event.playerName,
      playerId: playerId,
    );
  }

  Future<void> _loginUserAnonymous({bool forceLogin = false}) async {
    if (forceLogin || (await auth.isUserLoggedIn)) {
      await auth.signInAnonymously();
    }
  }

  Future<String> get userUid async => await auth.userId;
}
