import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  final _connectivity = Connectivity();
  late Stream<ConnectivityResult> _connectivityStream;

  /// Initialize connectivity monitoring
  void initialize() {
    _connectivityStream = _connectivity.onConnectivityChanged;
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Get connectivity status stream
  Stream<ConnectivityResult> getConnectivityStream() {
    return _connectivityStream;
  }

  /// Check specific connectivity type
  Future<bool> isWifi() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result == ConnectivityResult.wifi;
    } catch (e) {
      return false;
    }
  }

  /// Check mobile connectivity
  Future<bool> isMobile() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result == ConnectivityResult.mobile;
    } catch (e) {
      return false;
    }
  }
}
