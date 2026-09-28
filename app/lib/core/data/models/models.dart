/// Dart mirror of the API contract in `backend/app/schemas` (see docs/API.md).
///
/// Wire keys are snake_case (build.yaml sets `field_rename: snake`), enums carry the
/// exact Literal ids, and defaults match the Pydantic defaults. Every file in
/// `contracts/fixtures/` is parsed and round-tripped by `test/core/models_fixtures_test.dart`.
library;

export 'analysis.dart';
export 'common.dart';
export 'facilities.dart';
export 'health.dart';
export 'images.dart';
export 'recommend.dart';
export 'swaps.dart';
export 'tutorial.dart';
export 'vocab_enums.dart';
