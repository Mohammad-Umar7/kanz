import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'core_providers.dart';

/// GET /health. Read once at launch to wake the backend (cold starts load the
/// knowledge base), shown in Settings > Backend status. Refresh with
/// `ref.invalidate(healthProvider)`.
final healthProvider = FutureProvider<HealthResponse>(
  (ref) => ref.watch(apiClientProvider).health(),
  // Two quick retries cover a backend that is still starting; after that the
  // status stays "unreachable" until the user or a network change refreshes it.
  retry: (count, error) => count < 2 ? const Duration(seconds: 2) : null,
);

/// True while the phone has a network interface up.
final networkAvailableProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield await service.hasNetwork();
  yield* service.onNetworkChanged;
});

enum BackendStatus {
  /// Health check in flight.
  checking,

  /// Backend answered /health.
  online,

  /// The phone has no network at all (airplane mode).
  offline,

  /// Network is up but the backend did not answer (wrong URL, server down).
  unreachable,
}

/// One status for offline banners and Settings. Re-checks health whenever the
/// network comes back.
final backendStatusProvider = Provider<BackendStatus>((ref) {
  ref.listen(networkAvailableProvider, (previous, next) {
    if (previous?.value == false && next.value == true) {
      ref.invalidate(healthProvider);
    }
  });
  if (ref.watch(networkAvailableProvider).value == false) {
    return BackendStatus.offline;
  }
  return switch (ref.watch(healthProvider)) {
    AsyncData() => BackendStatus.online,
    AsyncError() => BackendStatus.unreachable,
    _ => BackendStatus.checking,
  };
});
