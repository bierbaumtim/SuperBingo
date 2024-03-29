import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'configuration_utils.dart';

/// {@template connection}
/// Singleton um auf Internetverbindungsänderungen zu reagieren
/// und um die aktuelle Verbindung abzurufen.
/// {@endtemplate}
class Connection {
  /// {@macro connection}
  static final Connection instance = Connection._internal();

  /// {@macro connection}
  factory Connection() => instance;

  Connection._internal() {
    _hasConnection = false;
    _currentConnectivityResult = ConnectivityResult.none;
  }

  StreamSubscription<ConnectivityResult>? _connectivityListener;
  late bool _hasConnection;
  late ConnectivityResult _currentConnectivityResult;

  ///
  bool get hasConnection => _hasConnection;

  /// Aktuelle Netzwerkbverbindung bzw. verbindungsart. Die Verbindungsart, garantiert aber keine
  /// aktive Internetverbindung. Dafür muss der getter `hasConnetion` genutzt werden.
  ///
  /// `wifi` - Verbindung mit dem Wlan
  /// `mobile` - Mobile Datenverbindung
  /// `none` - keine Internetverbindung
  ConnectivityResult get currentConnectiviyResult => _currentConnectivityResult;

  /// Initialisiert das Singleton und ruft alle nötigen Informationen erstmalig ab.
  /// Aktuelle Verbindungsart wird abgerufen.
  /// Es wird überprüft, ob eine aktive Internetverbindung besteht.
  /// StreamSubscription für Netzwerkänderungen wird initialisiert.
  Future<void> initConnection() async {
    if (isDesktop) {
      _currentConnectivityResult = ConnectivityResult.wifi;
      _hasConnection = await isConnected;
      _connectivityListener =
          const Stream<ConnectivityResult>.empty().listen((_) {});
    } else {
      _currentConnectivityResult = await Connectivity().checkConnectivity();
      _hasConnection = await isConnected;
      _connectivityListener =
          Connectivity().onConnectivityChanged.listen((connection) async {
        _hasConnection = await isConnected;
      });
    }
  }

  /// Startet einen lookup um zu überprüfen, ob eine Internetverbindung besteht.
  Future<bool> get isConnected async {
    if (kIsWeb) return true;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on Object catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      return false;
    }
    return false;
  }

  /// Beendet die StreamSubscription auf Netzwerkänderungen
  void dispose() {
    _connectivityListener?.cancel();
  }
}
