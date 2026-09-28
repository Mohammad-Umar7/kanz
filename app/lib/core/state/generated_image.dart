import 'package:freezed_annotation/freezed_annotation.dart';

import '../network/api_exception.dart';

part 'generated_image.freezed.dart';

enum ImageStatus {
  /// Not requested yet (later tutorial steps wait for earlier ones).
  idle,

  /// Being generated or downloaded; show a skeleton.
  loading,

  /// [GeneratedImageState.url] and usually [GeneratedImageState.localPath] are set.
  ready,

  /// See [GeneratedImageState.error]; offer regenerate.
  failed,
}

/// One generated image (an idea's after image or a tutorial step image).
///
/// Prefer [localPath] (works offline, no flash on rebuild) and fall back to
/// [url] while the download to the device is still running.
@freezed
abstract class GeneratedImageState with _$GeneratedImageState {
  const factory GeneratedImageState({
    @Default(ImageStatus.idle) ImageStatus status,

    /// Absolute URL on the backend.
    String? url,

    /// Copy in the documents directory.
    String? localPath,
    ApiException? error,
  }) = _GeneratedImageState;

  const GeneratedImageState._();

  bool get isReady => status == ImageStatus.ready;
  bool get isLoading => status == ImageStatus.loading;
}
