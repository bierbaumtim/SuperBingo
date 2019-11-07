import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';

class Connection {
  static final Connection instance = Connection._internal();

  factory Connection() => instance;

  Connection._internal();

  StreamSubscription<ConnectivityResult> _connectivityListener;
  bool _hasConnection;
  ConnectivityResult _currentConnectivityResult;

  bool get hasConnection => _hasConnection;
  ConnectivityResult get currentConnectiviyResult => _currentConnectivityResult;

  Future<void> initConnection() async {
    _currentConnectivityResult = await Connectivity().checkConnectivity();
    _hasConnection = await isConnected;
    _connectivityListener = Connectivity().onConnectivityChanged.listen((connection) async {
      _hasConnection = await isConnected;
    });
  }

  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on dynamic catch (e) {
      print(e);
      return false;
    }
    return false;
  }

  void dispose() {
    _connectivityListener.cancel();
  }
}
