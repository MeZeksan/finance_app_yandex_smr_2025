import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamController<bool> _connectionController;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  Stream<bool> get connectionStream => _connectionController.stream;

  Future<void> initialize() async {
    _connectionController = StreamController<bool>.broadcast();
    
    // Проверяем начальное состояние сети
    await _checkConnection();
    
    // Слушаем изменения состояния сети
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    final List<ConnectivityResult> connectivityResults = await _connectivity.checkConnectivity();
    
    final bool hasConnection = connectivityResults.any((result) => 
      result == ConnectivityResult.wifi || 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet
    );
    
    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      _connectionController.add(_isConnected);
      print('Network status changed: ${_isConnected ? "Connected" : "Disconnected"}');
    }
  }

  void dispose() {
    _connectionController.close();
  }
} 