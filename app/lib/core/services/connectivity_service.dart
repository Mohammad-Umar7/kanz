import 'package:connectivity_plus/connectivity_plus.dart';

/// Whether the phone has any network interface up. Reaching the backend is a
/// separate question, answered by the health check (see connectivity providers).
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get onNetworkChanged =>
      _connectivity.onConnectivityChanged.map(_hasNetwork).distinct();

  Future<bool> hasNetwork() async =>
      _hasNetwork(await _connectivity.checkConnectivity());

  static bool _hasNetwork(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
