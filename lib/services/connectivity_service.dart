import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.isNotEmpty &&
          result.any((status) => status != ConnectivityResult.none);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  Stream<bool> get connectionStatusStream {
    return _connectivity.onConnectivityChanged.map((statusList) {
      return statusList.isNotEmpty &&
          statusList.any((status) => status != ConnectivityResult.none);
    });
  }
}
