// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonAppName => 'Kanz';

  @override
  String get commonBack => 'Back';

  @override
  String get commonBackendChecking => 'Checking the connection';

  @override
  String get commonBackendOffline => 'Offline';

  @override
  String get commonBackendOnline => 'Connected';

  @override
  String get commonBackendUnreachable => 'Server not reachable';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCo2eDisclaimer => 'Estimate, verify before quoting.';

  @override
  String commonCo2eKg(String kg) {
    return '$kg kg CO2e';
  }

  @override
  String get commonContinue => 'Continue';

  @override
  String commonDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get commonDifficultyEasy => 'Easy';

  @override
  String get commonDifficultyHard => 'Hard';

  @override
  String get commonDifficultyMedium => 'Medium';

  @override
  String commonDistanceKm(String km) {
    return '$km km';
  }

  @override
  String commonDistanceMeters(String meters) {
    return '$meters m';
  }

  @override
  String get commonDone => 'Done';

  @override
  String get commonErrorAiInvalidOutput =>
      'The AI\'s answer didn\'t make sense this time. Try again.';

  @override
  String get commonErrorAiQuotaExhausted =>
      'The AI quota on this server is used up for now.';

  @override
  String get commonErrorAiTimeout =>
      'The AI took too long to answer. Try again.';

  @override
  String get commonErrorAiUnavailable =>
      'The AI service is busy right now. Try again in a moment.';

  @override
  String get commonErrorBadRequest =>
      'Something in that request was off. Please try again.';

  @override
  String get commonErrorBadResponse =>
      'The server sent an answer Kanz didn\'t expect. Try again.';

  @override
  String get commonErrorCancelled => 'Cancelled.';

  @override
  String get commonErrorGeneric => 'Something went wrong. Try again.';

  @override
  String get commonErrorImageInvalid =>
      'That file isn\'t a photo Kanz can read. Try another one.';

  @override
  String get commonErrorImageTooLarge =>
      'That photo is too large. Try a smaller one.';

  @override
  String get commonErrorInternal =>
      'Something went wrong on our side. Try again.';

  @override
  String get commonErrorInterrupted =>
      'This step didn\'t finish last time. Try again.';

  @override
  String get commonErrorNotFound => 'Kanz can\'t find that anymore.';

  @override
  String get commonErrorOffline =>
      'Can\'t reach Kanz. Check your connection and try again.';

  @override
  String get commonErrorPlacesUnavailable =>
      'Drop-off points can\'t be loaded right now. Try again soon.';

  @override
  String get commonErrorRateLimited =>
      'Lots of requests at once. Wait a moment, then try again.';

  @override
  String get commonErrorTimeout =>
      'This is taking too long. Check your connection and try again.';

  @override
  String commonHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get commonJustNow => 'Just now';

  @override
  String get commonLanguageArabic => 'العربية';

  @override
  String get commonLanguageEnglish => 'English';

  @override
  String get commonLanguageSystem => 'Phone language';

  @override
  String get commonLevelHigh => 'High';

  @override
  String get commonLevelLow => 'Low';

  @override
  String get commonLevelMedium => 'Medium';

  @override
  String get commonLoading => 'Loading';

  @override
  String commonMinutes(int count) {
    return '$count min';
  }

  @override
  String commonMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String get commonNext => 'Next';

  @override
  String get commonOk => 'OK';

  @override
  String get commonOpenSettings => 'Open settings';

  @override
  String get commonPhotoBlurry => 'The photo is blurry';

  @override
  String get commonPhotoCluttered => 'Too many things in the frame';

  @override
  String get commonPhotoGlare => 'Glare is hiding the item';

  @override
  String get commonPhotoNoItems => 'No items found in the photo';

  @override
  String get commonPhotoTooClose => 'The item is too close';

  @override
  String get commonPhotoTooDark => 'The photo is too dark';

  @override
  String get commonPhotoTooFar => 'The item is too far away';

  @override
  String get commonRecyclableConditional => 'Recyclable after prep';

  @override
  String get commonRecyclableNo => 'Not recyclable';

  @override
  String get commonRecyclableYes => 'Recyclable';

  @override
  String get commonRegenerate => 'Try another image';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonSave => 'Save';

  @override
  String get commonShare => 'Share';

  @override
  String get commonSkillAdvanced => 'Advanced';

  @override
  String get commonSkillBeginner => 'Beginner';

  @override
  String get commonSkillIntermediate => 'Intermediate';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSpeechCareful => 'Careful';

  @override
  String get commonSpeechTip => 'Tip';

  @override
  String get commonStageDropoff => 'Locating drop-off points';

  @override
  String get commonStageIdeas => 'Checking safety and finding ideas';

  @override
  String get commonStageIdentifying => 'Identifying materials';

  @override
  String get commonStageMakeovers => 'Rendering makeovers';

  @override
  String commonStepNumber(int number) {
    return 'Step $number';
  }

  @override
  String commonStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get commonThemeDark => 'Dark';

  @override
  String get commonThemeLight => 'Light';

  @override
  String get commonThemeSystem => 'Match phone';

  @override
  String commonWeightKg(String kg) {
    return '$kg kg';
  }

  @override
  String get commonYesterday => 'Yesterday';
}
