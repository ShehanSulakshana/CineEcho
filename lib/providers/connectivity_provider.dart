import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  bool _hasNetworkError = false;
  bool get hasNetworkError => _hasNetworkError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  ConnectivityProvider() {
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _setNetworkError('Unable to check connectivity');
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final previousStatus = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    // Clear error when connection is restored
    if (_isConnected && _hasNetworkError) {
      _hasNetworkError = false;
      _errorMessage = '';
    }

    if (previousStatus != _isConnected || _hasNetworkError) {
      notifyListeners();
    }
  }

  /// Called when a network error occurs (HTTP error, timeout, etc.)
  void setNetworkError(String message) {
    _setNetworkError(message);
  }

  void _setNetworkError(String message) {
    _hasNetworkError = true;
    _errorMessage = message;
    _isConnected = false;
    notifyListeners();
  }

  /// Clear the error state and attempt to restore connection
  void clearError() {
    _hasNetworkError = false;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
