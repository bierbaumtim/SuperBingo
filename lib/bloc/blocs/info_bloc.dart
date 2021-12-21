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
    on<LoadInfos>(_handleLoadInfos);
    on<SetPlayerName>(_handleSetPlayerName);

    add(LoadInfos());
  }

  Future<void> _handleLoadInfos(
    LoadInfos event,
    Emitter<InfoState> emit,
  ) async {
    emit(InfosLoading());
    try {
      final prefs = await SharedPreferences.getInstance();

      final playerName = prefs.getString('playername') ?? '';
      await _loginUserAnonymous(forceLogin: true);
      final playerId = await userUid;
      if (playerId != null && playerName.isNotEmpty) {
        InformationStorage.instance.playerId = playerId;
        emit(
          InfosLoaded(playerName: playerName, playerId: playerId),
        );
      } else {
        InformationStorage.instance.playerId = '';
        emit(InfosEmpty());
      }
    } on Object catch (e, s) {
      await LogService.instance.recordError(e, s);

      emit(InfosEmpty());
    }
  }

  Future<void> _handleSetPlayerName(
    SetPlayerName event,
    Emitter<InfoState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playername', event.playerName);

    if (InformationStorage.instance.playerId.isEmpty) {
      await _loginUserAnonymous(forceLogin: true);
    }
    final playerId = await userUid;

    if (playerId != null && event.playerName.isNotEmpty) {
      InformationStorage.instance.playerId = playerId;
      emit(
        InfosLoaded(playerName: event.playerName, playerId: playerId),
      );
    } else {
      InformationStorage.instance.playerId = '';
      emit(InfosEmpty());
    }
  }

  Future<void> _loginUserAnonymous({bool forceLogin = false}) async {
    if (forceLogin || auth.isUserLoggedIn) {
      await auth.signInAnonymously();
    }
  }

  Future<String?> get userUid async => auth.userId;
}
