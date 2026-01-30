import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'connectivity_provider.dart';

/// Global error handler that reports network errors to ConnectivityProvider
class ErrorHandler {
  static void handleError(
    BuildContext context,
    dynamic error, [
    String? customMessage,
  ]) {
    debugPrint('Network Error: $error');

    final connectivityProvider = context.read<ConnectivityProvider>();

    String errorMessage = customMessage ?? 'Network error occurred';

    if (error is FormatException) {
      errorMessage = 'Invalid data received from server';
    } else if (error is TimeoutException) {
      errorMessage = 'Request timeout. Please check your connection';
    } else if (error.toString().contains('SocketException')) {
      errorMessage = 'No internet connection';
    } else if (error.toString().contains('Connection refused')) {
      errorMessage = 'Unable to connect to server';
    }

    connectivityProvider.setNetworkError(errorMessage);
  }

  /// Wrap a network call with error handling
  static Future<T?> tryNetworkCall<T>(
    Future<T> Function() networkCall,
    BuildContext context, {
    String? errorMessage,
  }) async {
    try {
      return await networkCall();
    } catch (e) {
      if (context.mounted) {
        handleError(context, e, errorMessage);
      }
      return null;
    }
  }
}
