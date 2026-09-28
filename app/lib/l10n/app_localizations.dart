import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Product name. Arabic uses the Arabic word for treasure.
  ///
  /// In en, this message translates to:
  /// **'Kanz'**
  String get commonAppName;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonBackendChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking the connection'**
  String get commonBackendChecking;

  /// No description provided for @commonBackendOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get commonBackendOffline;

  /// No description provided for @commonBackendOnline.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get commonBackendOnline;

  /// No description provided for @commonBackendUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Server not reachable'**
  String get commonBackendUnreachable;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Always shown next to the CO2e figure on the Impact tab.
  ///
  /// In en, this message translates to:
  /// **'Estimate, verify before quoting.'**
  String get commonCo2eDisclaimer;

  /// No description provided for @commonCo2eKg.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg CO2e'**
  String commonCo2eKg(String kg);

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String commonDaysAgo(int count);

  /// No description provided for @commonDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get commonDifficultyEasy;

  /// No description provided for @commonDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get commonDifficultyHard;

  /// No description provided for @commonDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get commonDifficultyMedium;

  /// No description provided for @commonDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String commonDistanceKm(String km);

  /// No description provided for @commonDistanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String commonDistanceMeters(String meters);

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonErrorAiInvalidOutput.
  ///
  /// In en, this message translates to:
  /// **'The AI\'s answer didn\'t make sense this time. Try again.'**
  String get commonErrorAiInvalidOutput;

  /// No description provided for @commonErrorAiQuotaExhausted.
  ///
  /// In en, this message translates to:
  /// **'The AI quota on this server is used up for now.'**
  String get commonErrorAiQuotaExhausted;

  /// No description provided for @commonErrorAiTimeout.
  ///
  /// In en, this message translates to:
  /// **'The AI took too long to answer. Try again.'**
  String get commonErrorAiTimeout;

  /// No description provided for @commonErrorAiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The AI service is busy right now. Try again in a moment.'**
  String get commonErrorAiUnavailable;

  /// No description provided for @commonErrorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Something in that request was off. Please try again.'**
  String get commonErrorBadRequest;

  /// No description provided for @commonErrorBadResponse.
  ///
  /// In en, this message translates to:
  /// **'The server sent an answer Kanz didn\'t expect. Try again.'**
  String get commonErrorBadResponse;

  /// No description provided for @commonErrorCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled.'**
  String get commonErrorCancelled;

  /// No description provided for @commonErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get commonErrorGeneric;

  /// No description provided for @commonErrorImageInvalid.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t a photo Kanz can read. Try another one.'**
  String get commonErrorImageInvalid;

  /// No description provided for @commonErrorImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That photo is too large. Try a smaller one.'**
  String get commonErrorImageTooLarge;

  /// No description provided for @commonErrorInternal.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Try again.'**
  String get commonErrorInternal;

  /// No description provided for @commonErrorInterrupted.
  ///
  /// In en, this message translates to:
  /// **'This step didn\'t finish last time. Try again.'**
  String get commonErrorInterrupted;

  /// No description provided for @commonErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Kanz can\'t find that anymore.'**
  String get commonErrorNotFound;

  /// No description provided for @commonErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach Kanz. Check your connection and try again.'**
  String get commonErrorOffline;

  /// No description provided for @commonErrorPlacesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Drop-off points can\'t be loaded right now. Try again soon.'**
  String get commonErrorPlacesUnavailable;

  /// No description provided for @commonErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Lots of requests at once. Wait a moment, then try again.'**
  String get commonErrorRateLimited;

  /// No description provided for @commonErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'This is taking too long. Check your connection and try again.'**
  String get commonErrorTimeout;

  /// No description provided for @commonHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String commonHoursAgo(int count);

  /// No description provided for @commonJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get commonJustNow;

  /// Always written in Arabic, in both languages.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get commonLanguageArabic;

  /// No description provided for @commonLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get commonLanguageEnglish;

  /// No description provided for @commonLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get commonLanguageSystem;

  /// No description provided for @commonLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get commonLevelHigh;

  /// No description provided for @commonLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get commonLevelLow;

  /// No description provided for @commonLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get commonLevelMedium;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get commonLoading;

  /// No description provided for @commonMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String commonMinutes(int count);

  /// No description provided for @commonMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} min ago}}'**
  String commonMinutesAgo(int count);

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get commonOpenSettings;

  /// No description provided for @commonPhotoBlurry.
  ///
  /// In en, this message translates to:
  /// **'The photo is blurry'**
  String get commonPhotoBlurry;

  /// No description provided for @commonPhotoCluttered.
  ///
  /// In en, this message translates to:
  /// **'Too many things in the frame'**
  String get commonPhotoCluttered;

  /// No description provided for @commonPhotoGlare.
  ///
  /// In en, this message translates to:
  /// **'Glare is hiding the item'**
  String get commonPhotoGlare;

  /// No description provided for @commonPhotoNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items found in the photo'**
  String get commonPhotoNoItems;

  /// No description provided for @commonPhotoTooClose.
  ///
  /// In en, this message translates to:
  /// **'The item is too close'**
  String get commonPhotoTooClose;

  /// No description provided for @commonPhotoTooDark.
  ///
  /// In en, this message translates to:
  /// **'The photo is too dark'**
  String get commonPhotoTooDark;

  /// No description provided for @commonPhotoTooFar.
  ///
  /// In en, this message translates to:
  /// **'The item is too far away'**
  String get commonPhotoTooFar;

  /// No description provided for @commonRecyclableConditional.
  ///
  /// In en, this message translates to:
  /// **'Recyclable after prep'**
  String get commonRecyclableConditional;

  /// No description provided for @commonRecyclableNo.
  ///
  /// In en, this message translates to:
  /// **'Not recyclable'**
  String get commonRecyclableNo;

  /// No description provided for @commonRecyclableYes.
  ///
  /// In en, this message translates to:
  /// **'Recyclable'**
  String get commonRecyclableYes;

  /// Button that asks the backend for a new generated image.
  ///
  /// In en, this message translates to:
  /// **'Try another image'**
  String get commonRegenerate;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonSkillAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get commonSkillAdvanced;

  /// No description provided for @commonSkillBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get commonSkillBeginner;

  /// No description provided for @commonSkillIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get commonSkillIntermediate;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// Spoken before a step's warning in hands-free mode.
  ///
  /// In en, this message translates to:
  /// **'Careful'**
  String get commonSpeechCareful;

  /// Spoken before a step's tip in hands-free mode.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get commonSpeechTip;

  /// No description provided for @commonStageDropoff.
  ///
  /// In en, this message translates to:
  /// **'Locating drop-off points'**
  String get commonStageDropoff;

  /// No description provided for @commonStageIdeas.
  ///
  /// In en, this message translates to:
  /// **'Checking safety and finding ideas'**
  String get commonStageIdeas;

  /// No description provided for @commonStageIdentifying.
  ///
  /// In en, this message translates to:
  /// **'Identifying materials'**
  String get commonStageIdentifying;

  /// No description provided for @commonStageMakeovers.
  ///
  /// In en, this message translates to:
  /// **'Rendering makeovers'**
  String get commonStageMakeovers;

  /// No description provided for @commonStepNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String commonStepNumber(int number);

  /// No description provided for @commonStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String commonStepOf(int current, int total);

  /// No description provided for @commonThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get commonThemeDark;

  /// No description provided for @commonThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get commonThemeLight;

  /// No description provided for @commonThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Match phone'**
  String get commonThemeSystem;

  /// No description provided for @commonWeightKg.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg'**
  String commonWeightKg(String kg);

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
