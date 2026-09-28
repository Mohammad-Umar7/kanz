/// Localization entry point and shared formatters.
///
/// Strings live in per-feature fragments (`lib/l10n/src/<feature>_{en,ar}.arb`),
/// merged by `dart run tool/merge_arb.dart` and compiled by `flutter gen-l10n`.
///
/// Numbers policy: data (distances, weights, minutes, counts) keeps Western
/// digits in both languages, matching the mono data labels and the numbers the
/// AI writes inside Arabic text, so a figure reads the same everywhere.
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/data/models/models.dart';
import '../core/network/api_exception.dart';
import '../core/state/connectivity_providers.dart';
import '../core/state/scan_session_state.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Western-digit number formats, whatever the UI language.
final NumberFormat _integer = NumberFormat.decimalPattern('en');
final NumberFormat _oneDecimal = NumberFormat('#,##0.0', 'en');

/// Localized, human message for any API failure. Null means an unknown error.
String apiErrorMessage(AppLocalizations l10n, ApiException? error) =>
    switch (error?.code) {
      ApiErrorCode.badRequest => l10n.commonErrorBadRequest,
      ApiErrorCode.imageInvalid => l10n.commonErrorImageInvalid,
      ApiErrorCode.imageTooLarge => l10n.commonErrorImageTooLarge,
      ApiErrorCode.notFound => l10n.commonErrorNotFound,
      ApiErrorCode.rateLimited => l10n.commonErrorRateLimited,
      ApiErrorCode.aiUnavailable => l10n.commonErrorAiUnavailable,
      ApiErrorCode.aiTimeout => l10n.commonErrorAiTimeout,
      ApiErrorCode.aiInvalidOutput => l10n.commonErrorAiInvalidOutput,
      ApiErrorCode.aiQuotaExhausted => l10n.commonErrorAiQuotaExhausted,
      ApiErrorCode.placesUnavailable => l10n.commonErrorPlacesUnavailable,
      ApiErrorCode.internal => l10n.commonErrorInternal,
      ApiErrorCode.offline => l10n.commonErrorOffline,
      ApiErrorCode.timeout => l10n.commonErrorTimeout,
      ApiErrorCode.cancelled => l10n.commonErrorCancelled,
      ApiErrorCode.badResponse => l10n.commonErrorBadResponse,
      ApiErrorCode.interrupted => l10n.commonErrorInterrupted,
      null => l10n.commonErrorGeneric,
    };

/// What an error state quotes for support under `l10n.commonSupportCode`:
/// the request id, with the wire code in front of it in debug builds
/// ("ai_unavailable · req_5f3c2a1b"). Null when there is nothing to quote,
/// for example a failure with no request id in a release build.
String? errorSupportCode(ApiException? error) {
  if (error == null) return null;
  final id = error.requestId;
  if (!kDebugMode) return id;
  return [error.code.wireId, ?id].join(' · ');
}

String stageLabel(AppLocalizations l10n, PipelineStage stage) =>
    switch (stage) {
      PipelineStage.identifying => l10n.commonStageIdentifying,
      PipelineStage.ideas => l10n.commonStageIdeas,
      PipelineStage.dropoff => l10n.commonStageDropoff,
      PipelineStage.makeovers => l10n.commonStageMakeovers,
    };

String backendStatusLabel(AppLocalizations l10n, BackendStatus status) =>
    switch (status) {
      BackendStatus.online => l10n.commonBackendOnline,
      BackendStatus.checking => l10n.commonBackendChecking,
      BackendStatus.offline => l10n.commonBackendOffline,
      BackendStatus.unreachable => l10n.commonBackendUnreachable,
    };

String skillLabel(AppLocalizations l10n, SkillLevel skill) => switch (skill) {
  SkillLevel.beginner => l10n.commonSkillBeginner,
  SkillLevel.intermediate => l10n.commonSkillIntermediate,
  SkillLevel.advanced => l10n.commonSkillAdvanced,
};

String difficultyLabel(AppLocalizations l10n, Difficulty difficulty) =>
    switch (difficulty) {
      Difficulty.easy => l10n.commonDifficultyEasy,
      Difficulty.medium => l10n.commonDifficultyMedium,
      Difficulty.hard => l10n.commonDifficultyHard,
    };

String levelLabel(AppLocalizations l10n, Level level) => switch (level) {
  Level.low => l10n.commonLevelLow,
  Level.medium => l10n.commonLevelMedium,
  Level.high => l10n.commonLevelHigh,
};

String recyclabilityLabel(AppLocalizations l10n, RecyclabilityStatus status) =>
    switch (status) {
      RecyclabilityStatus.yes => l10n.commonRecyclableYes,
      RecyclabilityStatus.conditional => l10n.commonRecyclableConditional,
      RecyclabilityStatus.no => l10n.commonRecyclableNo,
    };

/// Short label for a rejected photo (the backend's `retake_tip` says what to do).
String? photoIssueLabel(AppLocalizations l10n, PhotoIssue issue) =>
    switch (issue) {
      PhotoIssue.ok => null,
      PhotoIssue.blurry => l10n.commonPhotoBlurry,
      PhotoIssue.tooDark => l10n.commonPhotoTooDark,
      PhotoIssue.tooFar => l10n.commonPhotoTooFar,
      PhotoIssue.tooClose => l10n.commonPhotoTooClose,
      PhotoIssue.cluttered => l10n.commonPhotoCluttered,
      PhotoIssue.noItems => l10n.commonPhotoNoItems,
      PhotoIssue.glare => l10n.commonPhotoGlare,
    };

/// "950 m", "2.7 km", "18 km".
String formatDistance(AppLocalizations l10n, int meters) {
  if (meters < 1000) {
    return l10n.commonDistanceMeters(
      _integer.format((meters / 10).round() * 10),
    );
  }
  final km = meters / 1000;
  return l10n.commonDistanceKm(
    km < 10 ? _oneDecimal.format(km) : _integer.format(km.round()),
  );
}

/// "0.4 kg", "12 kg".
String formatKg(AppLocalizations l10n, double kg) => l10n.commonWeightKg(
  kg < 10 ? _oneDecimal.format(kg) : _integer.format(kg.round()),
);

/// "1.2 kg CO₂e". Always pair it with `l10n.commonCo2eDisclaimer`.
String formatCo2e(AppLocalizations l10n, double kg) => l10n.commonCo2eKg(
  kg < 10 ? _oneDecimal.format(kg) : _integer.format(kg.round()),
);

/// Joins [items] with the language's own comma: "Recycling center, E-waste",
/// "مركز إعادة تدوير، نفايات إلكترونية". With [sentence], the last item is
/// joined with "and" / "و" as a sentence reads it: "glass, paper and metal",
/// "الزجاج، الورق، والمعادن".
String formatList(
  AppLocalizations l10n,
  Iterable<String> items, {
  bool sentence = false,
}) {
  final list = items.where((s) => s.trim().isNotEmpty).toList();
  final arabic = l10n.localeName.startsWith('ar');
  final comma = arabic ? '، ' : ', ';
  if (!sentence || list.length < 2) return list.join(comma);
  final head = list.sublist(0, list.length - 1);
  final last = list.last;
  if (arabic) {
    // "أ وب", then "أ، ب، وج" (the conjunction joins the last word).
    return list.length == 2
        ? '${head.single} و$last'
        : '${head.join(comma)}$commaو$last';
  }
  return '${head.join(comma)} and $last';
}

/// "Just now", "5 min ago", "3 hours ago", "Yesterday", "4 days ago", then a
/// date such as "12 Sep 2026" (month name localized, digits Western).
String formatRelative(AppLocalizations l10n, DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(time);
  if (diff.inMinutes < 1) return l10n.commonJustNow;
  if (diff.inHours < 1) return l10n.commonMinutesAgo(diff.inMinutes);
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(time.year, time.month, time.day);
  final days = today.difference(day).inDays;
  if (days == 0) return l10n.commonHoursAgo(diff.inHours);
  if (days == 1) return l10n.commonYesterday;
  if (days < 7) return l10n.commonDaysAgo(days);
  final month = DateFormat.MMM(l10n.localeName).format(time);
  return '${time.day} $month ${time.year}';
}
