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

  /// Always shown next to the CO₂e figure on the Impact tab.
  ///
  /// In en, this message translates to:
  /// **'Rough estimate from average factors.'**
  String get commonCo2eDisclaimer;

  /// No description provided for @commonCo2eKg.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg CO₂e'**
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
  /// **'Kanz hit an unexpected error.'**
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
  /// **'No connection. Saved scans and tutorials still open.'**
  String get commonErrorOffline;

  /// No description provided for @commonErrorPlacesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The map services didn\'t answer. Ideas and tutorials still work.'**
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

  /// Mono label over the request id at the end of an error state, for support.
  ///
  /// In en, this message translates to:
  /// **'Support code'**
  String get commonSupportCode;

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

  /// No description provided for @completionAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo of what you made'**
  String get completionAddPhoto;

  /// No description provided for @completionAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get completionAfter;

  /// No description provided for @completionAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get completionAllTime;

  /// No description provided for @completionBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get completionBefore;

  /// No description provided for @completionCameraAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow the camera'**
  String get completionCameraAllow;

  /// No description provided for @completionCameraBlocked.
  ///
  /// In en, this message translates to:
  /// **'The camera is turned off for Kanz in your phone\'s settings. You can choose a photo from your gallery instead.'**
  String get completionCameraBlocked;

  /// No description provided for @completionCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow the camera to photograph your project, or choose a photo you already took.'**
  String get completionCameraDenied;

  /// No description provided for @completionCameraNone.
  ///
  /// In en, this message translates to:
  /// **'This phone\'s camera couldn\'t be opened. You can choose a photo from your gallery instead.'**
  String get completionCameraNone;

  /// No description provided for @completionCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'The camera isn\'t available'**
  String get completionCameraTitle;

  /// No description provided for @completionCaptureGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get completionCaptureGallery;

  /// No description provided for @completionCaptureGuidance.
  ///
  /// In en, this message translates to:
  /// **'Photograph what you made'**
  String get completionCaptureGuidance;

  /// No description provided for @completionCaptureShutter.
  ///
  /// In en, this message translates to:
  /// **'Take the photo'**
  String get completionCaptureShutter;

  /// No description provided for @completionCaptureStarting.
  ///
  /// In en, this message translates to:
  /// **'Opening the camera'**
  String get completionCaptureStarting;

  /// No description provided for @completionCardMadeFrom.
  ///
  /// In en, this message translates to:
  /// **'Made from {item}'**
  String completionCardMadeFrom(String item);

  /// No description provided for @completionCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare your item before and after'**
  String get completionCompare;

  /// No description provided for @completionDescribedLabel.
  ///
  /// In en, this message translates to:
  /// **'You described'**
  String get completionDescribedLabel;

  /// No description provided for @completionErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Your project couldn\'t be read from this phone.'**
  String get completionErrorBody;

  /// No description provided for @completionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'The project didn\'t load'**
  String get completionErrorTitle;

  /// No description provided for @completionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Project finished'**
  String get completionEyebrow;

  /// No description provided for @completionEyebrowInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get completionEyebrowInProgress;

  /// No description provided for @completionFinishedOn.
  ///
  /// In en, this message translates to:
  /// **'Finished {date}'**
  String completionFinishedOn(String date);

  /// No description provided for @completionImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'What this project changed'**
  String get completionImpactTitle;

  /// No description provided for @completionItems.
  ///
  /// In en, this message translates to:
  /// **'Items kept out of the bin'**
  String get completionItems;

  /// No description provided for @completionLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your project'**
  String get completionLoading;

  /// No description provided for @completionMadeFrom.
  ///
  /// In en, this message translates to:
  /// **'Made from'**
  String get completionMadeFrom;

  /// No description provided for @completionMissingBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted with its scan. Your other projects are in History.'**
  String get completionMissingBody;

  /// No description provided for @completionMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'This project isn\'t on this phone'**
  String get completionMissingTitle;

  /// No description provided for @completionNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'You described this item in words, so there\'s no photo to compare.'**
  String get completionNoPhoto;

  /// No description provided for @completionNotFinished.
  ///
  /// In en, this message translates to:
  /// **'This project isn\'t finished yet.'**
  String get completionNotFinished;

  /// No description provided for @completionPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the photo. Try again.'**
  String get completionPhotoFailed;

  /// No description provided for @completionPhotoOnly.
  ///
  /// In en, this message translates to:
  /// **'The makeover image isn\'t available on this server, so this is your original photo.'**
  String get completionPhotoOnly;

  /// Label under the big number of items this project used.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{item kept out of the bin} other{items kept out of the bin}}'**
  String completionProjectItems(int count);

  /// No description provided for @completionProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects finished'**
  String get completionProjects;

  /// No description provided for @completionReplacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a new photo'**
  String get completionReplacePhoto;

  /// No description provided for @completionSavingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Saving your photo'**
  String get completionSavingPhoto;

  /// No description provided for @completionScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan something else'**
  String get completionScanAgain;

  /// No description provided for @completionSeeProjects.
  ///
  /// In en, this message translates to:
  /// **'See my projects'**
  String get completionSeeProjects;

  /// No description provided for @completionShare.
  ///
  /// In en, this message translates to:
  /// **'Share before and after'**
  String get completionShare;

  /// No description provided for @completionShareFallback.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t prepare the image, so only the text was shared.'**
  String get completionShareFallback;

  /// No description provided for @completionShareProject.
  ///
  /// In en, this message translates to:
  /// **'Share this project'**
  String get completionShareProject;

  /// No description provided for @completionShareText.
  ///
  /// In en, this message translates to:
  /// **'{title}, made from something I nearly threw away. Planned with Kanz.'**
  String completionShareText(String title);

  /// No description provided for @completionSharing.
  ///
  /// In en, this message translates to:
  /// **'Preparing the image'**
  String get completionSharing;

  /// No description provided for @completionSkill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get completionSkill;

  /// No description provided for @completionSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get completionSteps;

  /// No description provided for @completionStepsValue.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String completionStepsValue(int done, int total);

  /// No description provided for @completionStreak.
  ///
  /// In en, this message translates to:
  /// **'Days in a row'**
  String get completionStreak;

  /// No description provided for @completionThisProject.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{This project is now in your finished projects.} =1{This project kept 1 item out of the bin.} other{This project kept {count} items out of the bin.}}'**
  String completionThisProject(int count);

  /// No description provided for @completionTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get completionTime;

  /// No description provided for @dropoffAcceptedUnknown.
  ///
  /// In en, this message translates to:
  /// **'Accepted materials aren\'t listed. Check the bin labels before you go.'**
  String get dropoffAcceptedUnknown;

  /// No description provided for @dropoffAcceptsList.
  ///
  /// In en, this message translates to:
  /// **'Accepts {materials}'**
  String dropoffAcceptsList(String materials);

  /// No description provided for @dropoffApproximate.
  ///
  /// In en, this message translates to:
  /// **'Your location was approximate, so Kanz is searching around {city}.'**
  String dropoffApproximate(String city);

  /// No description provided for @dropoffCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get dropoffCall;

  /// No description provided for @dropoffCatalogError.
  ///
  /// In en, this message translates to:
  /// **'Filters didn\'t load.'**
  String get dropoffCatalogError;

  /// No description provided for @dropoffCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Materials to drop off'**
  String get dropoffCategoriesLabel;

  /// No description provided for @dropoffChangeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get dropoffChangeLocation;

  /// No description provided for @dropoffChangeLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Change where to search'**
  String get dropoffChangeLocationHint;

  /// No description provided for @dropoffCities.
  ///
  /// In en, this message translates to:
  /// **'Cities'**
  String get dropoffCities;

  /// No description provided for @dropoffClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get dropoffClosed;

  /// No description provided for @dropoffDetailAccepts.
  ///
  /// In en, this message translates to:
  /// **'Accepts'**
  String get dropoffDetailAccepts;

  /// No description provided for @dropoffDetailAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get dropoffDetailAddress;

  /// No description provided for @dropoffDetailDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get dropoffDetailDistance;

  /// No description provided for @dropoffDetailHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get dropoffDetailHours;

  /// No description provided for @dropoffDetailSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get dropoffDetailSource;

  /// No description provided for @dropoffDirectionOfPlace.
  ///
  /// In en, this message translates to:
  /// **'{direction, select, n{North of {place} centre} ne{North-east of {place} centre} e{East of {place} centre} se{South-east of {place} centre} s{South of {place} centre} sw{South-west of {place} centre} w{West of {place} centre} nw{North-west of {place} centre} other{Near {place} centre}}'**
  String dropoffDirectionOfPlace(String direction, String place);

  /// No description provided for @dropoffDirectionOfYou.
  ///
  /// In en, this message translates to:
  /// **'{direction, select, n{North of you} ne{North-east of you} e{East of you} se{South-east of you} s{South of you} sw{South-west of you} w{West of you} nw{North-west of you} other{Near you}}'**
  String dropoffDirectionOfYou(String direction);

  /// No description provided for @dropoffDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get dropoffDirections;

  /// No description provided for @dropoffDirectionsTo.
  ///
  /// In en, this message translates to:
  /// **'Directions to {name}'**
  String dropoffDirectionsTo(String name);

  /// No description provided for @dropoffEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Choose another city'**
  String get dropoffEmptyAction;

  /// No description provided for @dropoffEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No drop-off points for these materials near {place}. Try another city, or add a material above.'**
  String dropoffEmptyMessage(String place);

  /// No description provided for @dropoffEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing within {km} km'**
  String dropoffEmptyTitle(int km);

  /// No description provided for @dropoffErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop-off points didn\'t load'**
  String get dropoffErrorTitle;

  /// No description provided for @dropoffHoursUnknown.
  ///
  /// In en, this message translates to:
  /// **'Hours not listed'**
  String get dropoffHoursUnknown;

  /// No description provided for @dropoffLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding where to search'**
  String get dropoffLocating;

  /// No description provided for @dropoffLocationAllow.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get dropoffLocationAllow;

  /// No description provided for @dropoffLocationBlockedCity.
  ///
  /// In en, this message translates to:
  /// **'Or choose a city, and Kanz searches around its centre.'**
  String get dropoffLocationBlockedCity;

  /// No description provided for @dropoffLocationBlockedReason.
  ///
  /// In en, this message translates to:
  /// **'Turn it on in your phone\'s settings to sort places by distance from you.'**
  String get dropoffLocationBlockedReason;

  /// No description provided for @dropoffLocationBlockedSnack.
  ///
  /// In en, this message translates to:
  /// **'Location is off for Kanz. Turn it on in your phone\'s settings.'**
  String get dropoffLocationBlockedSnack;

  /// No description provided for @dropoffLocationBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location is off for Kanz'**
  String get dropoffLocationBlockedTitle;

  /// No description provided for @dropoffLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location wasn\'t allowed. You can choose a city instead.'**
  String get dropoffLocationDenied;

  /// No description provided for @dropoffLocationFootnote.
  ///
  /// In en, this message translates to:
  /// **'You can change this at any time from the top of this tab.'**
  String get dropoffLocationFootnote;

  /// No description provided for @dropoffLocationPickCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get dropoffLocationPickCity;

  /// No description provided for @dropoffLocationReasonDistance.
  ///
  /// In en, this message translates to:
  /// **'Places are sorted by how far they are from you.'**
  String get dropoffLocationReasonDistance;

  /// No description provided for @dropoffLocationReasonHazard.
  ///
  /// In en, this message translates to:
  /// **'Batteries and electronics go to places that take them.'**
  String get dropoffLocationReasonHazard;

  /// No description provided for @dropoffLocationSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kanz lists drop-off points within {km} km.'**
  String dropoffLocationSheetSubtitle(int km);

  /// No description provided for @dropoffLocationSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Search near'**
  String get dropoffLocationSheetTitle;

  /// No description provided for @dropoffLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Find drop-off points near you'**
  String get dropoffLocationTitle;

  /// No description provided for @dropoffNearCity.
  ///
  /// In en, this message translates to:
  /// **'Near {city}'**
  String dropoffNearCity(String city);

  /// No description provided for @dropoffNearYou.
  ///
  /// In en, this message translates to:
  /// **'Near you'**
  String get dropoffNearYou;

  /// No description provided for @dropoffNoCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one material above to see drop-off points near you.'**
  String get dropoffNoCategoryMessage;

  /// No description provided for @dropoffNoCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a material'**
  String get dropoffNoCategoryTitle;

  /// No description provided for @dropoffOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop-off points need a connection'**
  String get dropoffOfflineTitle;

  /// No description provided for @dropoffOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that. Try again.'**
  String get dropoffOpenFailed;

  /// No description provided for @dropoffOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get dropoffOpenNow;

  /// No description provided for @dropoffPlaceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place} other{{count} places}}'**
  String dropoffPlaceCount(int count);

  /// No description provided for @dropoffPlotCentreOf.
  ///
  /// In en, this message translates to:
  /// **'{city} centre'**
  String dropoffPlotCentreOf(String city);

  /// No description provided for @dropoffPlotLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drop-off point around {place}, {distance} away.} other{{count} drop-off points around {place}. The nearest is {distance} away.}}'**
  String dropoffPlotLabel(int count, String place, String distance);

  /// Key under the drop-off plot, next to a filled dot: the place lists what it accepts.
  ///
  /// In en, this message translates to:
  /// **'Materials listed'**
  String get dropoffPlotListed;

  /// Compass letter for north on the drop-off plot.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get dropoffPlotNorth;

  /// No description provided for @dropoffPlotRings.
  ///
  /// In en, this message translates to:
  /// **'Rings every {distance}'**
  String dropoffPlotRings(String distance);

  /// Key under the drop-off plot, next to a hollow ring: the place does not list what it accepts.
  ///
  /// In en, this message translates to:
  /// **'Not listed'**
  String get dropoffPlotUnlisted;

  /// No description provided for @dropoffPlotYou.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get dropoffPlotYou;

  /// No description provided for @dropoffSearching.
  ///
  /// In en, this message translates to:
  /// **'Looking for drop-off points'**
  String get dropoffSearching;

  /// No description provided for @dropoffSearchingNear.
  ///
  /// In en, this message translates to:
  /// **'Searching near {place}'**
  String dropoffSearchingNear(String place);

  /// No description provided for @dropoffSearchingNearYou.
  ///
  /// In en, this message translates to:
  /// **'Searching near you'**
  String get dropoffSearchingNearYou;

  /// No description provided for @dropoffSourceCurated.
  ///
  /// In en, this message translates to:
  /// **'Kanz list, checked by the team'**
  String get dropoffSourceCurated;

  /// Attribution for places from Google. Keep the product name as is.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get dropoffSourceGoogle;

  /// No description provided for @dropoffSourceOsm.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get dropoffSourceOsm;

  /// No description provided for @dropoffSourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get dropoffSourcesLabel;

  /// Title of the Drop-off tab.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get dropoffTitle;

  /// No description provided for @dropoffTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get dropoffTypeAll;

  /// No description provided for @dropoffTypeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 type} other{{count} types}}'**
  String dropoffTypeCount(int count);

  /// No description provided for @dropoffTypeEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Places were found nearby, but none match the type you picked.'**
  String get dropoffTypeEmptyMessage;

  /// No description provided for @dropoffTypeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No places of this type'**
  String get dropoffTypeEmptyTitle;

  /// No description provided for @dropoffTypeFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter by type of place'**
  String get dropoffTypeFilterHint;

  /// No description provided for @dropoffTypeSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show only the kinds of places you want to visit.'**
  String get dropoffTypeSheetSubtitle;

  /// No description provided for @dropoffTypeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Type of place'**
  String get dropoffTypeSheetTitle;

  /// No description provided for @dropoffTypeShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all types'**
  String get dropoffTypeShowAll;

  /// No description provided for @dropoffUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get dropoffUseMyLocation;

  /// No description provided for @dropoffUseMyLocationDetail.
  ///
  /// In en, this message translates to:
  /// **'Sorts places by distance from where you are'**
  String get dropoffUseMyLocationDetail;

  /// No description provided for @dropoffViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get dropoffViewList;

  /// No description provided for @dropoffViewMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get dropoffViewMap;

  /// No description provided for @dropoffWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get dropoffWebsite;

  /// The space before km is a no-break space, so the figure and unit stay on one line.
  ///
  /// In en, this message translates to:
  /// **'within {km} km'**
  String dropoffWithinKm(int km);

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete scan'**
  String get historyDelete;

  /// No description provided for @historyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Its photo, ideas and projects are removed from this phone. Your impact numbers stay.'**
  String get historyDeleteBody;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDeleteConfirm;

  /// No description provided for @historyDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'The scan couldn\'t be deleted. Try again.'**
  String get historyDeleteFailed;

  /// No description provided for @historyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this scan?'**
  String get historyDeleteTitle;

  /// No description provided for @historyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Scan deleted'**
  String get historyDeleted;

  /// No description provided for @historyErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Your saved scans and projects couldn\'t be read from this phone.'**
  String get historyErrorBody;

  /// No description provided for @historyErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'History didn\'t load'**
  String get historyErrorTitle;

  /// No description provided for @historyFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get historyFinished;

  /// No description provided for @historyFinishedOn.
  ///
  /// In en, this message translates to:
  /// **'Finished {date}'**
  String historyFinishedOn(String date);

  /// No description provided for @historyInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get historyInProgress;

  /// No description provided for @historyLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your history'**
  String get historyLoading;

  /// No description provided for @historyMore.
  ///
  /// In en, this message translates to:
  /// **'More options for {title}'**
  String historyMore(String title);

  /// No description provided for @historyNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Tutorial not opened yet'**
  String get historyNotStarted;

  /// No description provided for @historyOpenScan.
  ///
  /// In en, this message translates to:
  /// **'Open scan'**
  String get historyOpenScan;

  /// No description provided for @historyProjectsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Pick an upcycling idea from a scan and start its tutorial. Your progress is kept here.'**
  String get historyProjectsEmptyBody;

  /// No description provided for @historyProjectsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get historyProjectsEmptyTitle;

  /// No description provided for @historyResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get historyResume;

  /// No description provided for @historyScansEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Every item you scan is saved here and opens even without a connection.'**
  String get historyScansEmptyBody;

  /// No description provided for @historyScansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get historyScansEmptyTitle;

  /// No description provided for @historySeeProject.
  ///
  /// In en, this message translates to:
  /// **'See project'**
  String get historySeeProject;

  /// No description provided for @historyStepsDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} steps done'**
  String historyStepsDone(int done, int total);

  /// No description provided for @historyTabProjects.
  ///
  /// In en, this message translates to:
  /// **'My projects'**
  String get historyTabProjects;

  /// No description provided for @historyTabScans.
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get historyTabScans;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyToday;

  /// No description provided for @homeDescribe.
  ///
  /// In en, this message translates to:
  /// **'Describe it'**
  String get homeDescribe;

  /// Mono label on the tile of a scan made from a typed description instead of a photo.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get homeDescription;

  /// No description provided for @homeErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Your saved scans couldn\'t be read from this phone.'**
  String get homeErrorMessage;

  /// No description provided for @homeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your scans didn\'t load'**
  String get homeErrorTitle;

  /// No description provided for @homeGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get homeGallery;

  /// No description provided for @homeGuideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'What to photograph'**
  String get homeGuideEyebrow;

  /// No description provided for @homeGuideGlass.
  ///
  /// In en, this message translates to:
  /// **'Jars and bottles'**
  String get homeGuideGlass;

  /// No description provided for @homeGuideHazardous.
  ///
  /// In en, this message translates to:
  /// **'Batteries and old phones. Kanz shows where to take them safely.'**
  String get homeGuideHazardous;

  /// No description provided for @homeGuideMetal.
  ///
  /// In en, this message translates to:
  /// **'Tins and drink cans'**
  String get homeGuideMetal;

  /// No description provided for @homeGuidePaper.
  ///
  /// In en, this message translates to:
  /// **'Cardboard boxes and newspapers'**
  String get homeGuidePaper;

  /// No description provided for @homeGuideTextile.
  ///
  /// In en, this message translates to:
  /// **'T-shirts, jeans and fabric scraps'**
  String get homeGuideTextile;

  /// No description provided for @homeGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with something from your kitchen or wardrobe.'**
  String get homeGuideTitle;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'What are you about to throw away?'**
  String get homeHeadline;

  /// No description provided for @homeHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get homeHistory;

  /// No description provided for @homeImpactItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{item out of the bin} other{items out of the bin}}'**
  String homeImpactItems(int count);

  /// No description provided for @homeImpactOpen.
  ///
  /// In en, this message translates to:
  /// **'See your impact'**
  String get homeImpactOpen;

  /// No description provided for @homeImpactProjects.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{project finished} other{projects finished}}'**
  String homeImpactProjects(int count);

  /// No description provided for @homeImpactStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day in a row} other{days in a row}}'**
  String homeImpactStreak(int count);

  /// No description provided for @homeImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'Your impact'**
  String get homeImpactTitle;

  /// No description provided for @homeItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String homeItemCount(int count);

  /// No description provided for @homeLead.
  ///
  /// In en, this message translates to:
  /// **'Photograph it and Kanz shows what it\'s made of and what it could become.'**
  String get homeLead;

  /// No description provided for @homeLoadingRecent.
  ///
  /// In en, this message translates to:
  /// **'Loading your recent scans'**
  String get homeLoadingRecent;

  /// No description provided for @homeRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent scans'**
  String get homeRecentTitle;

  /// No description provided for @homeResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get homeResume;

  /// No description provided for @homeResumeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Continue your project'**
  String get homeResumeEyebrow;

  /// No description provided for @homeResumeNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Tutorial not opened yet'**
  String get homeResumeNotStarted;

  /// No description provided for @homeResumeProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String homeResumeProgress(int current, int total);

  /// No description provided for @homeScan.
  ///
  /// In en, this message translates to:
  /// **'Scan an item'**
  String get homeScan;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeTip1.
  ///
  /// In en, this message translates to:
  /// **'One item at a time, filling most of the frame.'**
  String get homeTip1;

  /// No description provided for @homeTip2.
  ///
  /// In en, this message translates to:
  /// **'A plain background and even light.'**
  String get homeTip2;

  /// No description provided for @homeTip3.
  ///
  /// In en, this message translates to:
  /// **'Show labels or recycling marks if it has any.'**
  String get homeTip3;

  /// No description provided for @homeTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'For a clear photo'**
  String get homeTipsTitle;

  /// No description provided for @homeUnfinishedScan.
  ///
  /// In en, this message translates to:
  /// **'Unfinished scan'**
  String get homeUnfinishedScan;

  /// No description provided for @ideaAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get ideaAfter;

  /// No description provided for @ideaBackToResults.
  ///
  /// In en, this message translates to:
  /// **'Back to results'**
  String get ideaBackToResults;

  /// No description provided for @ideaBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on'**
  String get ideaBasedOn;

  /// No description provided for @ideaBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get ideaBefore;

  /// No description provided for @ideaCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare before and after'**
  String get ideaCompare;

  /// No description provided for @ideaDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get ideaDifficulty;

  /// No description provided for @ideaDragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to compare'**
  String get ideaDragHint;

  /// No description provided for @ideaEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Idea {index} of {total}'**
  String ideaEyebrow(int index, int total);

  /// No description provided for @ideaFromDescription.
  ///
  /// In en, this message translates to:
  /// **'From your description'**
  String get ideaFromDescription;

  /// No description provided for @ideaImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Makeover didn\'t render'**
  String get ideaImageFailed;

  /// No description provided for @ideaImagePaused.
  ///
  /// In en, this message translates to:
  /// **'Makeover images paused'**
  String get ideaImagePaused;

  /// No description provided for @ideaMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Also needed'**
  String get ideaMaterialsTitle;

  /// No description provided for @ideaMissingBody.
  ///
  /// In en, this message translates to:
  /// **'The ideas for this scan changed. Go back to see the current ones.'**
  String get ideaMissingBody;

  /// No description provided for @ideaMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'This idea isn\'t available anymore'**
  String get ideaMissingTitle;

  /// No description provided for @ideaNoTools.
  ///
  /// In en, this message translates to:
  /// **'No tools needed, just your hands.'**
  String get ideaNoTools;

  /// No description provided for @ideaRendering.
  ///
  /// In en, this message translates to:
  /// **'Rendering the makeover'**
  String get ideaRendering;

  /// No description provided for @ideaSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get ideaSafety;

  /// No description provided for @ideaSeeTutorial.
  ///
  /// In en, this message translates to:
  /// **'See the tutorial'**
  String get ideaSeeTutorial;

  /// No description provided for @ideaTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get ideaTime;

  /// No description provided for @ideaToolHave.
  ///
  /// In en, this message translates to:
  /// **'You have it'**
  String get ideaToolHave;

  /// No description provided for @ideaToolMissing.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need it'**
  String get ideaToolMissing;

  /// No description provided for @ideaTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get ideaTools;

  /// No description provided for @ideaToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools needed'**
  String get ideaToolsTitle;

  /// No description provided for @impactActiveToday.
  ///
  /// In en, this message translates to:
  /// **'Active today'**
  String get impactActiveToday;

  /// No description provided for @impactByMaterial.
  ///
  /// In en, this message translates to:
  /// **'By material'**
  String get impactByMaterial;

  /// No description provided for @impactByPath.
  ///
  /// In en, this message translates to:
  /// **'Where they went'**
  String get impactByPath;

  /// No description provided for @impactCo2Label.
  ///
  /// In en, this message translates to:
  /// **'Emissions avoided'**
  String get impactCo2Label;

  /// No description provided for @impactEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Scan something you\'re about to throw away, then upcycle, recycle or donate it. Each item you mark shows up here.'**
  String get impactEmptyMessage;

  /// No description provided for @impactEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your impact starts with one scan'**
  String get impactEmptyTitle;

  /// No description provided for @impactErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your impact didn\'t load'**
  String get impactErrorTitle;

  /// No description provided for @impactEstimateLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get impactEstimateLabel;

  /// No description provided for @impactHowItems.
  ///
  /// In en, this message translates to:
  /// **'Items you mark as recycled, donated or disposed of safely from a scan\'s results.'**
  String get impactHowItems;

  /// No description provided for @impactHowProjects.
  ///
  /// In en, this message translates to:
  /// **'Upcycling projects you finish, step by step.'**
  String get impactHowProjects;

  /// No description provided for @impactHowStreak.
  ///
  /// In en, this message translates to:
  /// **'Days in a row with a scan, a marked item or a finished project.'**
  String get impactHowStreak;

  /// No description provided for @impactHowTitle.
  ///
  /// In en, this message translates to:
  /// **'What counts here'**
  String get impactHowTitle;

  /// No description provided for @impactIntro.
  ///
  /// In en, this message translates to:
  /// **'Counted from what you scanned and marked on this phone.'**
  String get impactIntro;

  /// No description provided for @impactItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String impactItemCount(int count);

  /// No description provided for @impactItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items kept out of the bin'**
  String get impactItemsLabel;

  /// No description provided for @impactKeepStreak.
  ///
  /// In en, this message translates to:
  /// **'Scan or mark one thing today so your streak keeps going.'**
  String get impactKeepStreak;

  /// No description provided for @impactKindDisposed.
  ///
  /// In en, this message translates to:
  /// **'Disposed of safely'**
  String get impactKindDisposed;

  /// No description provided for @impactKindDonated.
  ///
  /// In en, this message translates to:
  /// **'Donated'**
  String get impactKindDonated;

  /// No description provided for @impactKindRecycled.
  ///
  /// In en, this message translates to:
  /// **'Recycled'**
  String get impactKindRecycled;

  /// No description provided for @impactKindUpcycled.
  ///
  /// In en, this message translates to:
  /// **'Upcycled'**
  String get impactKindUpcycled;

  /// No description provided for @impactLoading.
  ///
  /// In en, this message translates to:
  /// **'Adding up your impact'**
  String get impactLoading;

  /// No description provided for @impactMassLabel.
  ///
  /// In en, this message translates to:
  /// **'Material kept from landfill'**
  String get impactMassLabel;

  /// No description provided for @impactNoItemsYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing marked yet. Open a scan\'s results and mark an item as recycled, donated or upcycled to count it here.'**
  String get impactNoItemsYet;

  /// No description provided for @impactProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Projects finished'**
  String get impactProjectsLabel;

  /// No description provided for @impactScanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan an item'**
  String get impactScanAction;

  /// No description provided for @impactStartStreak.
  ///
  /// In en, this message translates to:
  /// **'Scan something today to start a new streak.'**
  String get impactStartStreak;

  /// No description provided for @impactStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get impactStreakLabel;

  /// Title of the Impact tab.
  ///
  /// In en, this message translates to:
  /// **'Your impact'**
  String get impactTitle;

  /// No description provided for @onboardingChangeLater.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings.'**
  String get onboardingChangeLater;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Start using Kanz'**
  String get onboardingFinish;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Always written in Arabic, in both languages: it describes the Arabic option.
  ///
  /// In en, this message translates to:
  /// **'الأفكار والدروس والصوت بالعربية.'**
  String get onboardingLanguageArabicSample;

  /// No description provided for @onboardingLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'Menus, ideas, tutorials and spoken steps all follow it.'**
  String get onboardingLanguageBody;

  /// Always written in English, in both languages: it describes the English option.
  ///
  /// In en, this message translates to:
  /// **'Ideas, tutorials and voice in English.'**
  String get onboardingLanguageEnglishSample;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingSkillAdvancedLine.
  ///
  /// In en, this message translates to:
  /// **'You measure, saw, sew and finish with care.'**
  String get onboardingSkillAdvancedLine;

  /// No description provided for @onboardingSkillBeginnerLine.
  ///
  /// In en, this message translates to:
  /// **'Cutting, gluing and painting. No power tools.'**
  String get onboardingSkillBeginnerLine;

  /// No description provided for @onboardingSkillBody.
  ///
  /// In en, this message translates to:
  /// **'Tutorials match your level. Beginners get simpler steps and more detail.'**
  String get onboardingSkillBody;

  /// No description provided for @onboardingSkillIntermediateLine.
  ///
  /// In en, this message translates to:
  /// **'Comfortable with a drill, sandpaper and a needle.'**
  String get onboardingSkillIntermediateLine;

  /// No description provided for @onboardingSkillLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level} of 3'**
  String onboardingSkillLevel(int level);

  /// No description provided for @onboardingSkillTitle.
  ///
  /// In en, this message translates to:
  /// **'How handy are you?'**
  String get onboardingSkillTitle;

  /// No description provided for @onboardingToolGroupBuilding.
  ///
  /// In en, this message translates to:
  /// **'Drilling and fixing'**
  String get onboardingToolGroupBuilding;

  /// No description provided for @onboardingToolGroupCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String onboardingToolGroupCount(int selected, int total);

  /// No description provided for @onboardingToolGroupCutting.
  ///
  /// In en, this message translates to:
  /// **'Cutting'**
  String get onboardingToolGroupCutting;

  /// No description provided for @onboardingToolGroupFinishing.
  ///
  /// In en, this message translates to:
  /// **'Sanding and painting'**
  String get onboardingToolGroupFinishing;

  /// No description provided for @onboardingToolGroupJoining.
  ///
  /// In en, this message translates to:
  /// **'Gluing and fastening'**
  String get onboardingToolGroupJoining;

  /// No description provided for @onboardingToolGroupMeasuring.
  ///
  /// In en, this message translates to:
  /// **'Measuring'**
  String get onboardingToolGroupMeasuring;

  /// No description provided for @onboardingToolGroupOther.
  ///
  /// In en, this message translates to:
  /// **'Other tools'**
  String get onboardingToolGroupOther;

  /// No description provided for @onboardingToolGroupSewing.
  ///
  /// In en, this message translates to:
  /// **'Sewing'**
  String get onboardingToolGroupSewing;

  /// No description provided for @onboardingToolsBody.
  ///
  /// In en, this message translates to:
  /// **'Ideas and tutorials use only these. Safety gear is always listed.'**
  String get onboardingToolsBody;

  /// No description provided for @onboardingToolsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tools selected} =1{1 tool selected} other{{count} tools selected}}'**
  String onboardingToolsCount(int count);

  /// No description provided for @onboardingToolsNone.
  ///
  /// In en, this message translates to:
  /// **'No tools? That\'s fine. Ideas that need none come first.'**
  String get onboardingToolsNone;

  /// No description provided for @onboardingToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Which tools do you have?'**
  String get onboardingToolsTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Photograph something you\'re about to throw away and Kanz tells you what it\'s made of and what to do with it.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingWelcomeStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Materials, condition and quantity from one photo.'**
  String get onboardingWelcomeStep1Body;

  /// No description provided for @onboardingWelcomeStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Photograph an item'**
  String get onboardingWelcomeStep1Title;

  /// No description provided for @onboardingWelcomeStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Upcycle it with a step-by-step tutorial, recycle it or donate it.'**
  String get onboardingWelcomeStep2Body;

  /// No description provided for @onboardingWelcomeStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Choose a path'**
  String get onboardingWelcomeStep2Title;

  /// No description provided for @onboardingWelcomeStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Recycling and donation points near you.'**
  String get onboardingWelcomeStep3Body;

  /// No description provided for @onboardingWelcomeStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Drop it off'**
  String get onboardingWelcomeStep3Title;

  /// Welcome headline. Kanz means treasure in Arabic.
  ///
  /// In en, this message translates to:
  /// **'Find the treasure in what you throw away.'**
  String get onboardingWelcomeTitle;

  /// No description provided for @permissionsAsking.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your answer'**
  String get permissionsAsking;

  /// No description provided for @permissionsCameraAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get permissionsCameraAllow;

  /// No description provided for @permissionsCameraBlocked.
  ///
  /// In en, this message translates to:
  /// **'The camera is turned off for Kanz in your phone\'s settings. Turn it on there, or pick a photo from your gallery.'**
  String get permissionsCameraBlocked;

  /// No description provided for @permissionsCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'The camera wasn\'t allowed. Ask again, or pick a photo from your gallery.'**
  String get permissionsCameraDenied;

  /// No description provided for @permissionsCameraGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery instead'**
  String get permissionsCameraGallery;

  /// No description provided for @permissionsCameraReason1.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at an item and Kanz names its materials and condition.'**
  String get permissionsCameraReason1;

  /// No description provided for @permissionsCameraReason2.
  ///
  /// In en, this message translates to:
  /// **'Only the photo you take is sent for analysis, with its location data removed.'**
  String get permissionsCameraReason2;

  /// No description provided for @permissionsCameraReason3.
  ///
  /// In en, this message translates to:
  /// **'Rather not? Pick a photo from your gallery instead.'**
  String get permissionsCameraReason3;

  /// No description provided for @permissionsCameraRestricted.
  ///
  /// In en, this message translates to:
  /// **'The camera can\'t be turned on for Kanz on this phone. Pick a photo from your gallery instead.'**
  String get permissionsCameraRestricted;

  /// No description provided for @permissionsCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Kanz what you\'re about to throw away'**
  String get permissionsCameraTitle;

  /// No description provided for @permissionsCityBody.
  ///
  /// In en, this message translates to:
  /// **'Kanz looks for drop-off points around the city centre. You can change it any time in Settings.'**
  String get permissionsCityBody;

  /// No description provided for @permissionsCityEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Emirates'**
  String get permissionsCityEyebrow;

  /// No description provided for @permissionsCitySelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get permissionsCitySelected;

  /// No description provided for @permissionsCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your city'**
  String get permissionsCityTitle;

  /// No description provided for @permissionsCityUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location instead'**
  String get permissionsCityUseLocation;

  /// No description provided for @permissionsCityUseLocationDetail.
  ///
  /// In en, this message translates to:
  /// **'More precise: points sorted by distance from you'**
  String get permissionsCityUseLocationDetail;

  /// No description provided for @permissionsFootnote.
  ///
  /// In en, this message translates to:
  /// **'You can change this any time in Settings.'**
  String get permissionsFootnote;

  /// No description provided for @permissionsLocationAllow.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get permissionsLocationAllow;

  /// No description provided for @permissionsLocationBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off for Kanz in your phone\'s settings. Turn it on there, or choose a city.'**
  String get permissionsLocationBlocked;

  /// No description provided for @permissionsLocationCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city instead'**
  String get permissionsLocationCity;

  /// No description provided for @permissionsLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location wasn\'t allowed. Ask again, or choose a city.'**
  String get permissionsLocationDenied;

  /// No description provided for @permissionsLocationReason1.
  ///
  /// In en, this message translates to:
  /// **'Recycling and donation points are sorted by distance from you.'**
  String get permissionsLocationReason1;

  /// No description provided for @permissionsLocationReason2.
  ///
  /// In en, this message translates to:
  /// **'Kanz reads your position only when it searches for drop-off points.'**
  String get permissionsLocationReason2;

  /// No description provided for @permissionsLocationReason3.
  ///
  /// In en, this message translates to:
  /// **'Rather not? Choose your city and Kanz searches around its centre.'**
  String get permissionsLocationReason3;

  /// No description provided for @permissionsLocationRestricted.
  ///
  /// In en, this message translates to:
  /// **'Location can\'t be turned on for Kanz on this phone. Choose a city instead.'**
  String get permissionsLocationRestricted;

  /// No description provided for @permissionsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Find drop-off points near you'**
  String get permissionsLocationTitle;

  /// No description provided for @permissionsNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get permissionsNotAllowed;

  /// No description provided for @permissionsTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'Turned off in Settings'**
  String get permissionsTurnedOff;

  /// No description provided for @permissionsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this phone'**
  String get permissionsUnavailable;

  /// No description provided for @resultsAccepts.
  ///
  /// In en, this message translates to:
  /// **'Accepts {materials}'**
  String resultsAccepts(String materials);

  /// No description provided for @resultsAroundCity.
  ///
  /// In en, this message translates to:
  /// **'Around {city}, since your location was approximate'**
  String resultsAroundCity(String city);

  /// No description provided for @resultsAttribution.
  ///
  /// In en, this message translates to:
  /// **'Places from {sources}'**
  String resultsAttribution(String sources);

  /// No description provided for @resultsBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on'**
  String get resultsBasedOn;

  /// No description provided for @resultsBeforeYouGo.
  ///
  /// In en, this message translates to:
  /// **'Before you go'**
  String get resultsBeforeYouGo;

  /// No description provided for @resultsBoxSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {category}, {confidence} confidence'**
  String resultsBoxSemantics(String name, String category, String confidence);

  /// No description provided for @resultsChooseCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get resultsChooseCity;

  /// No description provided for @resultsChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get resultsChooseFromGallery;

  /// No description provided for @resultsClosedNow.
  ///
  /// In en, this message translates to:
  /// **'Closed now'**
  String get resultsClosedNow;

  /// No description provided for @resultsCorrectedNote.
  ///
  /// In en, this message translates to:
  /// **'Corrected by you.'**
  String get resultsCorrectedNote;

  /// No description provided for @resultsDescribeAgain.
  ///
  /// In en, this message translates to:
  /// **'Describe it again'**
  String get resultsDescribeAgain;

  /// No description provided for @resultsDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions to {name}'**
  String resultsDirections(String name);

  /// No description provided for @resultsDirectionsFailed.
  ///
  /// In en, this message translates to:
  /// **'Maps didn\'t open. Try again in a moment.'**
  String get resultsDirectionsFailed;

  /// No description provided for @resultsDisposalNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get resultsDisposalNever;

  /// No description provided for @resultsDisposalSteps.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get resultsDisposalSteps;

  /// No description provided for @resultsDo.
  ///
  /// In en, this message translates to:
  /// **'Do'**
  String get resultsDo;

  /// No description provided for @resultsDonateNotSuitable.
  ///
  /// In en, this message translates to:
  /// **'Not suitable to donate'**
  String get resultsDonateNotSuitable;

  /// No description provided for @resultsDonateSuitable.
  ///
  /// In en, this message translates to:
  /// **'Good to donate'**
  String get resultsDonateSuitable;

  /// No description provided for @resultsDonateUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Not one to donate'**
  String get resultsDonateUnavailableTitle;

  /// No description provided for @resultsDonateWhere.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get resultsDonateWhere;

  /// No description provided for @resultsDoneIn.
  ///
  /// In en, this message translates to:
  /// **'Done in {seconds} s'**
  String resultsDoneIn(String seconds);

  /// No description provided for @resultsDont.
  ///
  /// In en, this message translates to:
  /// **'Don\'t'**
  String get resultsDont;

  /// No description provided for @resultsDropoffErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop-off points didn\'t load'**
  String get resultsDropoffErrorTitle;

  /// No description provided for @resultsDropoffTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop-off near you'**
  String get resultsDropoffTitle;

  /// No description provided for @resultsDropoffWaiting.
  ///
  /// In en, this message translates to:
  /// **'Drop-off points appear once Kanz knows what this is.'**
  String get resultsDropoffWaiting;

  /// No description provided for @resultsEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get resultsEditCategory;

  /// No description provided for @resultsEditHazards.
  ///
  /// In en, this message translates to:
  /// **'Hazards'**
  String get resultsEditHazards;

  /// No description provided for @resultsEditItem.
  ///
  /// In en, this message translates to:
  /// **'Correct this item'**
  String get resultsEditItem;

  /// No description provided for @resultsEditMaterial.
  ///
  /// In en, this message translates to:
  /// **'Specific material'**
  String get resultsEditMaterial;

  /// No description provided for @resultsEditMaterialHint.
  ///
  /// In en, this message translates to:
  /// **'For example: clear glass, PET #1'**
  String get resultsEditMaterialHint;

  /// No description provided for @resultsEditName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get resultsEditName;

  /// No description provided for @resultsEditQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get resultsEditQuality;

  /// No description provided for @resultsEditQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get resultsEditQuantity;

  /// No description provided for @resultsEditQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number, like 2 or 0.5'**
  String get resultsEditQuantityInvalid;

  /// No description provided for @resultsEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save and update ideas'**
  String get resultsEditSave;

  /// No description provided for @resultsEditState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get resultsEditState;

  /// No description provided for @resultsEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kanz will update the ideas with your changes.'**
  String get resultsEditSubtitle;

  /// No description provided for @resultsEditUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get resultsEditUnit;

  /// No description provided for @resultsFindingIdeas.
  ///
  /// In en, this message translates to:
  /// **'Finding ideas that suit your tools'**
  String get resultsFindingIdeas;

  /// No description provided for @resultsFocusItem.
  ///
  /// In en, this message translates to:
  /// **'Focus ideas on this item'**
  String get resultsFocusItem;

  /// No description provided for @resultsFocusedItem.
  ///
  /// In en, this message translates to:
  /// **'Ideas below are for the {item}'**
  String resultsFocusedItem(String item);

  /// No description provided for @resultsHazardLabel.
  ///
  /// In en, this message translates to:
  /// **'{hazards}: safe disposal only, no DIY'**
  String resultsHazardLabel(String hazards);

  /// No description provided for @resultsHeldBackBody.
  ///
  /// In en, this message translates to:
  /// **'{items} can\'t be used for DIY.'**
  String resultsHeldBackBody(String items);

  /// No description provided for @resultsHeldBackPointer.
  ///
  /// In en, this message translates to:
  /// **'How to get rid of it safely follows the ideas.'**
  String get resultsHeldBackPointer;

  /// No description provided for @resultsHeldBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Held back from DIY'**
  String get resultsHeldBackTitle;

  /// No description provided for @resultsHideSteps.
  ///
  /// In en, this message translates to:
  /// **'Hide steps'**
  String get resultsHideSteps;

  /// No description provided for @resultsHoursUnknown.
  ///
  /// In en, this message translates to:
  /// **'Hours not listed'**
  String get resultsHoursUnknown;

  /// No description provided for @resultsIdeaBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get resultsIdeaBefore;

  /// No description provided for @resultsIdeaImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview unavailable'**
  String get resultsIdeaImageFailed;

  /// No description provided for @resultsIdeaImagePaused.
  ///
  /// In en, this message translates to:
  /// **'Image generation paused'**
  String get resultsIdeaImagePaused;

  /// No description provided for @resultsIdeaImageRetry.
  ///
  /// In en, this message translates to:
  /// **'Try the image again'**
  String get resultsIdeaImageRetry;

  /// No description provided for @resultsIdeaRendering.
  ///
  /// In en, this message translates to:
  /// **'Rendering the makeover'**
  String get resultsIdeaRendering;

  /// No description provided for @resultsIdeasErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Ideas didn\'t load'**
  String get resultsIdeasErrorTitle;

  /// No description provided for @resultsIdentifyErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Kanz couldn\'t identify the materials'**
  String get resultsIdentifyErrorTitle;

  /// No description provided for @resultsImagesPausedBody.
  ///
  /// In en, this message translates to:
  /// **'This server can\'t draw pictures right now. The ideas and their step-by-step tutorials still work.'**
  String get resultsImagesPausedBody;

  /// No description provided for @resultsImagesPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Makeover images paused'**
  String get resultsImagesPausedTitle;

  /// No description provided for @resultsInCity.
  ///
  /// In en, this message translates to:
  /// **'In {city}'**
  String resultsInCity(String city);

  /// No description provided for @resultsItemsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item found} other{{count} items found}}'**
  String resultsItemsFound(int count);

  /// No description provided for @resultsLabelConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get resultsLabelConfidence;

  /// No description provided for @resultsLabelMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get resultsLabelMaterial;

  /// No description provided for @resultsLabelQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get resultsLabelQuality;

  /// No description provided for @resultsLabelQuantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get resultsLabelQuantity;

  /// No description provided for @resultsLabelRecyclable.
  ///
  /// In en, this message translates to:
  /// **'Recyclable'**
  String get resultsLabelRecyclable;

  /// No description provided for @resultsLabelState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get resultsLabelState;

  /// No description provided for @resultsLabelType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get resultsLabelType;

  /// No description provided for @resultsListAnd.
  ///
  /// In en, this message translates to:
  /// **'{first} and {last}'**
  String resultsListAnd(String first, String last);

  /// No description provided for @resultsLocationOff.
  ///
  /// In en, this message translates to:
  /// **'Location is off for Kanz, so pick a city instead.'**
  String get resultsLocationOff;

  /// No description provided for @resultsMarkDisposed.
  ///
  /// In en, this message translates to:
  /// **'Mark as disposed'**
  String get resultsMarkDisposed;

  /// No description provided for @resultsMarkDonated.
  ///
  /// In en, this message translates to:
  /// **'Mark as donated'**
  String get resultsMarkDonated;

  /// No description provided for @resultsMarkRecycled.
  ///
  /// In en, this message translates to:
  /// **'Mark as recycled'**
  String get resultsMarkRecycled;

  /// No description provided for @resultsMarkedDisposed.
  ///
  /// In en, this message translates to:
  /// **'Disposed · added to your impact'**
  String get resultsMarkedDisposed;

  /// No description provided for @resultsMarkedDonated.
  ///
  /// In en, this message translates to:
  /// **'Donated · added to your impact'**
  String get resultsMarkedDonated;

  /// No description provided for @resultsMarkedRecycled.
  ///
  /// In en, this message translates to:
  /// **'Recycled · added to your impact'**
  String get resultsMarkedRecycled;

  /// No description provided for @resultsMaterialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap an item to see its details.'**
  String get resultsMaterialsSubtitle;

  /// No description provided for @resultsMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'What it\'s made of'**
  String get resultsMaterialsTitle;

  /// No description provided for @resultsMissingBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted from History. Start a new scan to see ideas.'**
  String get resultsMissingBody;

  /// No description provided for @resultsMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'This scan isn\'t on this phone'**
  String get resultsMissingTitle;

  /// No description provided for @resultsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Near your location'**
  String get resultsNearYou;

  /// No description provided for @resultsNeedsLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Use your location or pick a city to see the nearest drop-off points.'**
  String get resultsNeedsLocationBody;

  /// No description provided for @resultsNeedsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where should Kanz look?'**
  String get resultsNeedsLocationTitle;

  /// No description provided for @resultsNewScan.
  ///
  /// In en, this message translates to:
  /// **'New scan'**
  String get resultsNewScan;

  /// No description provided for @resultsNoDiyTitle.
  ///
  /// In en, this message translates to:
  /// **'No DIY for this item'**
  String get resultsNoDiyTitle;

  /// No description provided for @resultsNoIdeasBody.
  ///
  /// In en, this message translates to:
  /// **'Recycling or donating may suit it better. If Kanz misread the item, correct it above.'**
  String get resultsNoIdeasBody;

  /// No description provided for @resultsNoIdeasTitle.
  ///
  /// In en, this message translates to:
  /// **'No DIY ideas for this one'**
  String get resultsNoIdeasTitle;

  /// No description provided for @resultsNoPlacesBody.
  ///
  /// In en, this message translates to:
  /// **'The Drop-off tab can search a wider set of places or another city.'**
  String get resultsNoPlacesBody;

  /// No description provided for @resultsNoPlacesTitle.
  ///
  /// In en, this message translates to:
  /// **'No drop-off points found nearby'**
  String get resultsNoPlacesTitle;

  /// No description provided for @resultsOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Saved results still open; new steps wait for a connection.'**
  String get resultsOffline;

  /// No description provided for @resultsOpenDropoff.
  ///
  /// In en, this message translates to:
  /// **'Open Drop-off'**
  String get resultsOpenDropoff;

  /// No description provided for @resultsOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get resultsOpenNow;

  /// No description provided for @resultsPathsTitle.
  ///
  /// In en, this message translates to:
  /// **'What it can become'**
  String get resultsPathsTitle;

  /// No description provided for @resultsPathsTitleDisposal.
  ///
  /// In en, this message translates to:
  /// **'How to get rid of it safely'**
  String get resultsPathsTitleDisposal;

  /// No description provided for @resultsPhotoSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Your photo} =1{Your photo, 1 item found} other{Your photo, {count} items found}}'**
  String resultsPhotoSemantics(int count);

  /// No description provided for @resultsPrep.
  ///
  /// In en, this message translates to:
  /// **'Prep'**
  String get resultsPrep;

  /// No description provided for @resultsQualitySemantics.
  ///
  /// In en, this message translates to:
  /// **'Quality {score} of 5, {label}'**
  String resultsQualitySemantics(int score, String label);

  /// No description provided for @resultsReadAs.
  ///
  /// In en, this message translates to:
  /// **'Kanz read this as'**
  String get resultsReadAs;

  /// No description provided for @resultsReadingItems.
  ///
  /// In en, this message translates to:
  /// **'Reading material, quantity and condition'**
  String get resultsReadingItems;

  /// No description provided for @resultsRecyclableValue.
  ///
  /// In en, this message translates to:
  /// **'{status} · {stream}'**
  String resultsRecyclableValue(String status, String stream);

  /// No description provided for @resultsRecycleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recycling steps came back for this scan.'**
  String get resultsRecycleEmpty;

  /// No description provided for @resultsRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get resultsRetake;

  /// No description provided for @resultsRetakeFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Kanz couldn\'t make out an item'**
  String get resultsRetakeFallbackTitle;

  /// No description provided for @resultsSafeDisposalTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe disposal'**
  String get resultsSafeDisposalTitle;

  /// No description provided for @resultsSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String resultsSeconds(String seconds);

  /// No description provided for @resultsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get resultsSeeAll;

  /// No description provided for @resultsShowSteps.
  ///
  /// In en, this message translates to:
  /// **'Show steps'**
  String get resultsShowSteps;

  /// No description provided for @resultsSourceCurated.
  ///
  /// In en, this message translates to:
  /// **'Kanz\'s own list'**
  String get resultsSourceCurated;

  /// No description provided for @resultsSourceGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get resultsSourceGoogle;

  /// No description provided for @resultsSourceOsm.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap contributors'**
  String get resultsSourceOsm;

  /// No description provided for @resultsStageImagesPaused.
  ///
  /// In en, this message translates to:
  /// **'Image generation is paused on this server. Ideas and tutorials still work.'**
  String get resultsStageImagesPaused;

  /// No description provided for @resultsStageNeedsLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose where to look, below.'**
  String get resultsStageNeedsLocation;

  /// No description provided for @resultsStageNoDropoff.
  ///
  /// In en, this message translates to:
  /// **'Nothing here needs a drop-off point.'**
  String get resultsStageNoDropoff;

  /// No description provided for @resultsStageNoMakeovers.
  ///
  /// In en, this message translates to:
  /// **'No ideas to render.'**
  String get resultsStageNoMakeovers;

  /// No description provided for @resultsStageNoMakeoversDisposal.
  ///
  /// In en, this message translates to:
  /// **'Nothing to render: this item needs safe disposal.'**
  String get resultsStageNoMakeoversDisposal;

  /// No description provided for @resultsSummaryDisposal.
  ///
  /// In en, this message translates to:
  /// **'safe disposal'**
  String get resultsSummaryDisposal;

  /// No description provided for @resultsSummaryIdeas.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no ideas} =1{1 idea} other{{count} ideas}}'**
  String resultsSummaryIdeas(int count);

  /// No description provided for @resultsSummaryImagesPaused.
  ///
  /// In en, this message translates to:
  /// **'Makeover images paused'**
  String get resultsSummaryImagesPaused;

  /// No description provided for @resultsSummaryPlaces.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no places nearby} =1{1 place} other{{count} places}}'**
  String resultsSummaryPlaces(int count);

  /// No description provided for @resultsTabDispose.
  ///
  /// In en, this message translates to:
  /// **'Dispose'**
  String get resultsTabDispose;

  /// No description provided for @resultsTabDonate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get resultsTabDonate;

  /// No description provided for @resultsTabRecycle.
  ///
  /// In en, this message translates to:
  /// **'Recycle'**
  String get resultsTabRecycle;

  /// No description provided for @resultsTabUpcycle.
  ///
  /// In en, this message translates to:
  /// **'Upcycle'**
  String get resultsTabUpcycle;

  /// No description provided for @resultsTextRejectedBody.
  ///
  /// In en, this message translates to:
  /// **'Name the item and what it\'s made of, for example: two empty plastic water bottles.'**
  String get resultsTextRejectedBody;

  /// No description provided for @resultsTextRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Kanz couldn\'t tell what that is'**
  String get resultsTextRejectedTitle;

  /// No description provided for @resultsTextScan.
  ///
  /// In en, this message translates to:
  /// **'Text scan'**
  String get resultsTextScan;

  /// No description provided for @resultsTip.
  ///
  /// In en, this message translates to:
  /// **'What to try'**
  String get resultsTip;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan results'**
  String get resultsTitle;

  /// No description provided for @resultsToolsAll.
  ///
  /// In en, this message translates to:
  /// **'You have every tool'**
  String get resultsToolsAll;

  /// No description provided for @resultsToolsNeeded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Needs 1 tool you don\'t have} other{Needs {count} tools you don\'t have}}'**
  String resultsToolsNeeded(int count);

  /// No description provided for @resultsToolsNone.
  ///
  /// In en, this message translates to:
  /// **'No tools needed'**
  String get resultsToolsNone;

  /// No description provided for @resultsToolsSome.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{You have {have} of 1 tool} other{You have {have} of {total} tools}}'**
  String resultsToolsSome(int have, int total);

  /// No description provided for @resultsUnitBag.
  ///
  /// In en, this message translates to:
  /// **'bags'**
  String get resultsUnitBag;

  /// No description provided for @resultsUnitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get resultsUnitG;

  /// No description provided for @resultsUnitHandful.
  ///
  /// In en, this message translates to:
  /// **'handfuls'**
  String get resultsUnitHandful;

  /// No description provided for @resultsUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get resultsUnitKg;

  /// No description provided for @resultsUnitL.
  ///
  /// In en, this message translates to:
  /// **'litres'**
  String get resultsUnitL;

  /// No description provided for @resultsUnitM.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get resultsUnitM;

  /// No description provided for @resultsUnitM2.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get resultsUnitM2;

  /// No description provided for @resultsUnitPcs.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get resultsUnitPcs;

  /// No description provided for @resultsUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get resultsUseMyLocation;

  /// No description provided for @scanBackToCamera.
  ///
  /// In en, this message translates to:
  /// **'Back to camera'**
  String get scanBackToCamera;

  /// No description provided for @scanCameraAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get scanCameraAllow;

  /// No description provided for @scanCameraBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off for Kanz. Turn it on in Settings, or use a photo from your gallery.'**
  String get scanCameraBlockedBody;

  /// No description provided for @scanCameraDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'You can still pick a photo you already took, or describe the item in a sentence.'**
  String get scanCameraDeniedBody;

  /// No description provided for @scanCameraDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Kanz can\'t use the camera'**
  String get scanCameraDeniedTitle;

  /// No description provided for @scanCameraUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Another app may be using it. Try again, or pick a photo from your gallery.'**
  String get scanCameraUnavailableBody;

  /// No description provided for @scanCameraUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'The camera isn\'t available'**
  String get scanCameraUnavailableTitle;

  /// No description provided for @scanChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get scanChooseFromGallery;

  /// No description provided for @scanDescribe.
  ///
  /// In en, this message translates to:
  /// **'Describe'**
  String get scanDescribe;

  /// No description provided for @scanDescribeBody.
  ///
  /// In en, this message translates to:
  /// **'Say what it is, what it\'s made of, how many there are and what shape they\'re in.'**
  String get scanDescribeBody;

  /// No description provided for @scanDescribeHint.
  ///
  /// In en, this message translates to:
  /// **'For example: three empty glass jars with metal lids'**
  String get scanDescribeHint;

  /// No description provided for @scanDescribeInstead.
  ///
  /// In en, this message translates to:
  /// **'Describe it instead'**
  String get scanDescribeInstead;

  /// No description provided for @scanDescribeLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get scanDescribeLabel;

  /// No description provided for @scanDescribeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Describe the item in words'**
  String get scanDescribeSemantics;

  /// No description provided for @scanDescribeStart.
  ///
  /// In en, this message translates to:
  /// **'Identify materials'**
  String get scanDescribeStart;

  /// No description provided for @scanDescribeTitle.
  ///
  /// In en, this message translates to:
  /// **'Describe what you have'**
  String get scanDescribeTitle;

  /// No description provided for @scanExampleBatteries.
  ///
  /// In en, this message translates to:
  /// **'Four used AA batteries'**
  String get scanExampleBatteries;

  /// No description provided for @scanExampleBox.
  ///
  /// In en, this message translates to:
  /// **'A big cardboard box from a delivery'**
  String get scanExampleBox;

  /// No description provided for @scanExampleJars.
  ///
  /// In en, this message translates to:
  /// **'Empty glass jam jars with metal lids'**
  String get scanExampleJars;

  /// No description provided for @scanExampleJeans.
  ///
  /// In en, this message translates to:
  /// **'A pile of old denim jeans'**
  String get scanExampleJeans;

  /// No description provided for @scanExampleSemantics.
  ///
  /// In en, this message translates to:
  /// **'Use the example: {example}'**
  String scanExampleSemantics(String example);

  /// No description provided for @scanExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Or start from an example'**
  String get scanExamplesTitle;

  /// No description provided for @scanGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get scanGallery;

  /// No description provided for @scanGalleryErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Allow Kanz to see your photos, then try again.'**
  String get scanGalleryErrorBody;

  /// No description provided for @scanGalleryErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your photos didn\'t open'**
  String get scanGalleryErrorTitle;

  /// No description provided for @scanGallerySemantics.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo from your gallery'**
  String get scanGallerySemantics;

  /// The single line of guidance on the viewfinder.
  ///
  /// In en, this message translates to:
  /// **'Fill the frame with one item, in good light'**
  String get scanGuidance;

  /// No description provided for @scanNoCameraBody.
  ///
  /// In en, this message translates to:
  /// **'This phone has no camera Kanz can use. Pick a photo or describe the item instead.'**
  String get scanNoCameraBody;

  /// No description provided for @scanOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Kanz needs a connection to identify materials.'**
  String get scanOffline;

  /// No description provided for @scanOpeningGallery.
  ///
  /// In en, this message translates to:
  /// **'Opening your photos'**
  String get scanOpeningGallery;

  /// No description provided for @scanShutter.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get scanShutter;

  /// No description provided for @scanStartingCamera.
  ///
  /// In en, this message translates to:
  /// **'Starting the camera'**
  String get scanStartingCamera;

  /// No description provided for @scanTextScan.
  ///
  /// In en, this message translates to:
  /// **'Text scan'**
  String get scanTextScan;

  /// Toggle for the camera light; announced as on or off.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get scanTorch;

  /// No description provided for @scanUseCamera.
  ///
  /// In en, this message translates to:
  /// **'Use the camera'**
  String get scanUseCamera;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'Kanz identifies what your things are made of, suggests how to upcycle, recycle or donate them, and finds drop-off points in the UAE.'**
  String get settingsAboutBody;

  /// Row under the fixed-city choice that opens the city picker; the city name follows in mono.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get settingsCity;

  /// No description provided for @settingsCo2eNote.
  ///
  /// In en, this message translates to:
  /// **'CO₂e figures in Kanz are estimates from average emission factors, not measurements.'**
  String get settingsCo2eNote;

  /// No description provided for @settingsEstimates.
  ///
  /// In en, this message translates to:
  /// **'Estimates'**
  String get settingsEstimates;

  /// No description provided for @settingsHandsFree.
  ///
  /// In en, this message translates to:
  /// **'Hands-free by default'**
  String get settingsHandsFree;

  /// No description provided for @settingsHandsFreeDetail.
  ///
  /// In en, this message translates to:
  /// **'Reads each step aloud and listens for \"next\", \"back\" and \"repeat\".'**
  String get settingsHandsFreeDetail;

  /// No description provided for @settingsKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Knowledge base'**
  String get settingsKnowledge;

  /// No description provided for @settingsKnowledgeDocs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 document} other{{count} documents}}'**
  String settingsKnowledgeDocs(int count);

  /// No description provided for @settingsKnowledgeKeyword.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 document, keyword search} other{{count} documents, keyword search}}'**
  String settingsKnowledgeKeyword(int count);

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageNote.
  ///
  /// In en, this message translates to:
  /// **'Ideas, tutorials and spoken steps use this language too.'**
  String get settingsLanguageNote;

  /// No description provided for @settingsLanguageSystemDetail.
  ///
  /// In en, this message translates to:
  /// **'Now {language}'**
  String settingsLanguageSystemDetail(String language);

  /// No description provided for @settingsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get settingsLicenses;

  /// No description provided for @settingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location for drop-off points'**
  String get settingsLocation;

  /// No description provided for @settingsLocationCity.
  ///
  /// In en, this message translates to:
  /// **'A fixed city'**
  String get settingsLocationCity;

  /// No description provided for @settingsLocationCityDetail.
  ///
  /// In en, this message translates to:
  /// **'Search around {city}'**
  String settingsLocationCityDetail(String city);

  /// No description provided for @settingsLocationCityNone.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get settingsLocationCityNone;

  /// No description provided for @settingsLocationGps.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get settingsLocationGps;

  /// No description provided for @settingsLocationGpsDetail.
  ///
  /// In en, this message translates to:
  /// **'Points sorted by distance from you'**
  String get settingsLocationGpsDetail;

  /// No description provided for @settingsLocationGpsOff.
  ///
  /// In en, this message translates to:
  /// **'Location access is off. Kanz uses your city until you allow it.'**
  String get settingsLocationGpsOff;

  /// No description provided for @settingsLocationGpsOffNoCity.
  ///
  /// In en, this message translates to:
  /// **'Location access is off. Allow it, or choose a city.'**
  String get settingsLocationGpsOffNoCity;

  /// No description provided for @settingsLocationUndecided.
  ///
  /// In en, this message translates to:
  /// **'Kanz asks the first time you look for drop-off points.'**
  String get settingsLocationUndecided;

  /// No description provided for @settingsModelEmbed.
  ///
  /// In en, this message translates to:
  /// **'Embeddings'**
  String get settingsModelEmbed;

  /// No description provided for @settingsModelImage.
  ///
  /// In en, this message translates to:
  /// **'Image model'**
  String get settingsModelImage;

  /// No description provided for @settingsModelText.
  ///
  /// In en, this message translates to:
  /// **'Text model'**
  String get settingsModelText;

  /// No description provided for @settingsModelVision.
  ///
  /// In en, this message translates to:
  /// **'Vision model'**
  String get settingsModelVision;

  /// No description provided for @settingsPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places sources'**
  String get settingsPlaces;

  /// No description provided for @settingsPlacesNone.
  ///
  /// In en, this message translates to:
  /// **'None configured'**
  String get settingsPlacesNone;

  /// No description provided for @settingsServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get settingsServer;

  /// No description provided for @settingsServerHelper.
  ///
  /// In en, this message translates to:
  /// **'Default: {url}'**
  String settingsServerHelper(String url);

  /// No description provided for @settingsServerInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a full address that starts with http:// or https://'**
  String get settingsServerInvalid;

  /// No description provided for @settingsServerNoAi.
  ///
  /// In en, this message translates to:
  /// **'No AI key is set on this server, so scans can\'t be analysed.'**
  String get settingsServerNoAi;

  /// No description provided for @settingsServerOfflineDetail.
  ///
  /// In en, this message translates to:
  /// **'This phone has no network connection.'**
  String get settingsServerOfflineDetail;

  /// No description provided for @settingsServerReset.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get settingsServerReset;

  /// No description provided for @settingsServerSave.
  ///
  /// In en, this message translates to:
  /// **'Save and test'**
  String get settingsServerSave;

  /// No description provided for @settingsServerTest.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get settingsServerTest;

  /// No description provided for @settingsServerTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing the connection'**
  String get settingsServerTesting;

  /// No description provided for @settingsServerUnreachableDetail.
  ///
  /// In en, this message translates to:
  /// **'Check the address, and that the server is running and on the same network.'**
  String get settingsServerUnreachableDetail;

  /// No description provided for @settingsServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get settingsServerUrl;

  /// No description provided for @settingsServerVersion.
  ///
  /// In en, this message translates to:
  /// **'Server version'**
  String get settingsServerVersion;

  /// No description provided for @settingsSkill.
  ///
  /// In en, this message translates to:
  /// **'Skill level'**
  String get settingsSkill;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTools.
  ///
  /// In en, this message translates to:
  /// **'My tools'**
  String get settingsTools;

  /// Separator between tool names in a list.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get settingsToolsListSeparator;

  /// No description provided for @settingsToolsMore.
  ///
  /// In en, this message translates to:
  /// **'{names} and {count} more'**
  String settingsToolsMore(String names, int count);

  /// No description provided for @settingsToolsNone.
  ///
  /// In en, this message translates to:
  /// **'None yet. Ideas that need no tools come first.'**
  String get settingsToolsNone;

  /// No description provided for @settingsTutorials.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get settingsTutorials;

  /// Settings > About row; the installed version (1.0.0 (1)) follows in mono.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Your workshop'**
  String get settingsWorkshop;

  /// No description provided for @shellChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking the connection'**
  String get shellChecking;

  /// Banner when the phone has no network at all.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Saved scans still open.'**
  String get shellOffline;

  /// Short action in the offline banner that checks the server again.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get shellRetry;

  /// Accessible name of the clay scan action in the middle of the navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Scan an item'**
  String get shellScan;

  /// No description provided for @shellTabDropoff.
  ///
  /// In en, this message translates to:
  /// **'Drop-off'**
  String get shellTabDropoff;

  /// No description provided for @shellTabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get shellTabHome;

  /// No description provided for @shellTabImpact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get shellTabImpact;

  /// No description provided for @shellTabSwaps.
  ///
  /// In en, this message translates to:
  /// **'Swaps'**
  String get shellTabSwaps;

  /// Banner when the network is up but the backend does not answer.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the Kanz server. Saved scans still open.'**
  String get shellUnreachable;

  /// No description provided for @swapsChipBatteries.
  ///
  /// In en, this message translates to:
  /// **'Batteries'**
  String get swapsChipBatteries;

  /// No description provided for @swapsChipClingFilm.
  ///
  /// In en, this message translates to:
  /// **'Cling film'**
  String get swapsChipClingFilm;

  /// No description provided for @swapsChipCoffeeCapsules.
  ///
  /// In en, this message translates to:
  /// **'Coffee capsules'**
  String get swapsChipCoffeeCapsules;

  /// No description provided for @swapsChipPaperTowels.
  ///
  /// In en, this message translates to:
  /// **'Paper towels'**
  String get swapsChipPaperTowels;

  /// No description provided for @swapsChipPlasticBags.
  ///
  /// In en, this message translates to:
  /// **'Plastic bags'**
  String get swapsChipPlasticBags;

  /// No description provided for @swapsChipPlasticBottles.
  ///
  /// In en, this message translates to:
  /// **'Plastic bottles'**
  String get swapsChipPlasticBottles;

  /// No description provided for @swapsChipTakeawayContainers.
  ///
  /// In en, this message translates to:
  /// **'Takeaway containers'**
  String get swapsChipTakeawayContainers;

  /// No description provided for @swapsChipWetWipes.
  ///
  /// In en, this message translates to:
  /// **'Wet wipes'**
  String get swapsChipWetWipes;

  /// No description provided for @swapsChipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Often in your bin'**
  String get swapsChipsLabel;

  /// What a swap costs, from Level ids low, medium, high.
  ///
  /// In en, this message translates to:
  /// **'{level, select, low{Low cost} medium{Medium cost} high{High cost} other{{level}}}'**
  String swapsCostLevel(String level);

  /// No description provided for @swapsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 swap} other{{count} swaps}}'**
  String swapsCount(int count);

  /// Effort a swap takes, from Level ids low, medium, high.
  ///
  /// In en, this message translates to:
  /// **'{level, select, low{Low effort} medium{Medium effort} high{High effort} other{{level}}}'**
  String swapsEffortLevel(String level);

  /// No description provided for @swapsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Kanz couldn\'t match those items. Try a common one, like plastic bottles or cling film.'**
  String get swapsEmptyMessage;

  /// No description provided for @swapsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No swaps for that yet'**
  String get swapsEmptyTitle;

  /// No description provided for @swapsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Swaps didn\'t load'**
  String get swapsErrorTitle;

  /// No description provided for @swapsFreeTextHelper.
  ///
  /// In en, this message translates to:
  /// **'Separate items with commas'**
  String get swapsFreeTextHelper;

  /// No description provided for @swapsFreeTextHint.
  ///
  /// In en, this message translates to:
  /// **'Straws, foil trays, razors'**
  String get swapsFreeTextHint;

  /// No description provided for @swapsFreeTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Add something else'**
  String get swapsFreeTextLabel;

  /// No description provided for @swapsFromScans.
  ///
  /// In en, this message translates to:
  /// **'From your scans'**
  String get swapsFromScans;

  /// No description provided for @swapsHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Also covers what you scanned today} other{Also covers what you scanned in the last {days} days}}'**
  String swapsHistorySubtitle(int days);

  /// No description provided for @swapsHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Use my scan history'**
  String get swapsHistoryTitle;

  /// No description provided for @swapsHowCost.
  ///
  /// In en, this message translates to:
  /// **'Effort and cost at a glance, with the sources behind it.'**
  String get swapsHowCost;

  /// No description provided for @swapsHowSwap.
  ///
  /// In en, this message translates to:
  /// **'One lasting alternative for each item you pick.'**
  String get swapsHowSwap;

  /// No description provided for @swapsHowTip.
  ///
  /// In en, this message translates to:
  /// **'Why it helps, and one tip to make the switch stick.'**
  String get swapsHowTip;

  /// No description provided for @swapsHowTitle.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get swapsHowTitle;

  /// No description provided for @swapsInsightLabel.
  ///
  /// In en, this message translates to:
  /// **'From your scans'**
  String get swapsInsightLabel;

  /// No description provided for @swapsInsteadOf.
  ///
  /// In en, this message translates to:
  /// **'Instead of'**
  String get swapsInsteadOf;

  /// No description provided for @swapsIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick what you throw away most. Kanz suggests a lasting alternative for each, with one tip to make it stick.'**
  String get swapsIntro;

  /// No description provided for @swapsLoading.
  ///
  /// In en, this message translates to:
  /// **'Finding swaps for {items}'**
  String swapsLoading(String items);

  /// No description provided for @swapsLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Finding swaps from your scan history'**
  String get swapsLoadingHistory;

  /// No description provided for @swapsOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Swaps need a connection'**
  String get swapsOfflineTitle;

  /// No description provided for @swapsResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Swaps for you'**
  String get swapsResultsTitle;

  /// No description provided for @swapsSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get swapsSources;

  /// No description provided for @swapsStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get swapsStartOver;

  /// No description provided for @swapsSubmit.
  ///
  /// In en, this message translates to:
  /// **'Find swaps'**
  String get swapsSubmit;

  /// No description provided for @swapsSubmitHint.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one item, or type your own.'**
  String get swapsSubmitHint;

  /// No description provided for @swapsTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get swapsTip;

  /// Title of the Swaps tab (eco-friendly alternatives).
  ///
  /// In en, this message translates to:
  /// **'Swaps'**
  String get swapsTitle;

  /// No description provided for @swapsTry.
  ///
  /// In en, this message translates to:
  /// **'Try'**
  String get swapsTry;

  /// No description provided for @swapsUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update swaps'**
  String get swapsUpdate;

  /// No description provided for @tutorialAdaptAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a tool'**
  String get tutorialAdaptAdd;

  /// No description provided for @tutorialAdaptBody.
  ///
  /// In en, this message translates to:
  /// **'Kanz rewrites the steps for your skill and the tools you have.'**
  String get tutorialAdaptBody;

  /// No description provided for @tutorialAdaptFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t rewrite the tutorial. {reason}'**
  String tutorialAdaptFailed(String reason);

  /// No description provided for @tutorialAdaptHave.
  ///
  /// In en, this message translates to:
  /// **'You have'**
  String get tutorialAdaptHave;

  /// No description provided for @tutorialAdaptOffline.
  ///
  /// In en, this message translates to:
  /// **'Adapting needs a connection.'**
  String get tutorialAdaptOffline;

  /// No description provided for @tutorialAdaptProgressNote.
  ///
  /// In en, this message translates to:
  /// **'Your progress starts over, because the steps change.'**
  String get tutorialAdaptProgressNote;

  /// No description provided for @tutorialAdaptSkill.
  ///
  /// In en, this message translates to:
  /// **'Your skill'**
  String get tutorialAdaptSkill;

  /// No description provided for @tutorialAdaptSubmit.
  ///
  /// In en, this message translates to:
  /// **'Rewrite the steps'**
  String get tutorialAdaptSubmit;

  /// No description provided for @tutorialAdaptTitle.
  ///
  /// In en, this message translates to:
  /// **'Adapt this tutorial'**
  String get tutorialAdaptTitle;

  /// No description provided for @tutorialAdaptToolsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Tools · none selected} other{Tools · {count} selected}}'**
  String tutorialAdaptToolsCount(int count);

  /// No description provided for @tutorialAdaptToolsHint.
  ///
  /// In en, this message translates to:
  /// **'Leave a tool off and Kanz works around it.'**
  String get tutorialAdaptToolsHint;

  /// No description provided for @tutorialAdaptTooltip.
  ///
  /// In en, this message translates to:
  /// **'Adapt to your skill and tools'**
  String get tutorialAdaptTooltip;

  /// Mono label above the backend's adapted_note line.
  ///
  /// In en, this message translates to:
  /// **'Your version'**
  String get tutorialAdaptedLabel;

  /// No description provided for @tutorialAdapting.
  ///
  /// In en, this message translates to:
  /// **'Rewriting for {skill} with your tools. The current steps stay here until the new ones arrive.'**
  String tutorialAdapting(String skill);

  /// No description provided for @tutorialAdaptingRow.
  ///
  /// In en, this message translates to:
  /// **'Adapting to your tools'**
  String get tutorialAdaptingRow;

  /// No description provided for @tutorialBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get tutorialBefore;

  /// No description provided for @tutorialCareLabel.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get tutorialCareLabel;

  /// No description provided for @tutorialCareful.
  ///
  /// In en, this message translates to:
  /// **'Careful'**
  String get tutorialCareful;

  /// No description provided for @tutorialChangeSetup.
  ///
  /// In en, this message translates to:
  /// **'Change skill or tools'**
  String get tutorialChangeSetup;

  /// No description provided for @tutorialCommandBack.
  ///
  /// In en, this message translates to:
  /// **'back'**
  String get tutorialCommandBack;

  /// No description provided for @tutorialCommandNext.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get tutorialCommandNext;

  /// No description provided for @tutorialCommandRepeat.
  ///
  /// In en, this message translates to:
  /// **'repeat'**
  String get tutorialCommandRepeat;

  /// No description provided for @tutorialContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue at step {number}'**
  String tutorialContinue(int number);

  /// No description provided for @tutorialDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get tutorialDismiss;

  /// No description provided for @tutorialErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'The tutorial didn\'t load'**
  String get tutorialErrorTitle;

  /// No description provided for @tutorialEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorialEyebrow;

  /// No description provided for @tutorialFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish project'**
  String get tutorialFinish;

  /// No description provided for @tutorialFinishEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Almost done'**
  String get tutorialFinishEyebrow;

  /// No description provided for @tutorialFinishFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the project. Try again.'**
  String get tutorialFinishFailed;

  /// No description provided for @tutorialFinishSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving your project'**
  String get tutorialFinishSaving;

  /// No description provided for @tutorialFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finishing and care'**
  String get tutorialFinishTitle;

  /// No description provided for @tutorialFinishingLabel.
  ///
  /// In en, this message translates to:
  /// **'Finishing'**
  String get tutorialFinishingLabel;

  /// No description provided for @tutorialFromScan.
  ///
  /// In en, this message translates to:
  /// **'From your scan'**
  String get tutorialFromScan;

  /// No description provided for @tutorialGearLabel.
  ///
  /// In en, this message translates to:
  /// **'Protective gear'**
  String get tutorialGearLabel;

  /// No description provided for @tutorialHandsFree.
  ///
  /// In en, this message translates to:
  /// **'Hands-free mode'**
  String get tutorialHandsFree;

  /// No description provided for @tutorialHandsFreeOn.
  ///
  /// In en, this message translates to:
  /// **'Hands-free is on'**
  String get tutorialHandsFreeOn;

  /// No description provided for @tutorialHandsFreeStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting hands-free'**
  String get tutorialHandsFreeStarting;

  /// No description provided for @tutorialHeard.
  ///
  /// In en, this message translates to:
  /// **'Heard “{command}”'**
  String tutorialHeard(String command);

  /// No description provided for @tutorialImageBlocked.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the image of step {number}'**
  String tutorialImageBlocked(int number);

  /// No description provided for @tutorialImageDrawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing step {number}'**
  String tutorialImageDrawing(int number);

  /// No description provided for @tutorialImageFailed.
  ///
  /// In en, this message translates to:
  /// **'This step\'s image didn\'t load'**
  String get tutorialImageFailed;

  /// No description provided for @tutorialImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Picture of step {number}: {title}'**
  String tutorialImageLabel(int number, String title);

  /// No description provided for @tutorialImageOffline.
  ///
  /// In en, this message translates to:
  /// **'Pictures need a connection'**
  String get tutorialImageOffline;

  /// No description provided for @tutorialImagePaused.
  ///
  /// In en, this message translates to:
  /// **'Image generation is paused on this server'**
  String get tutorialImagePaused;

  /// No description provided for @tutorialImageQueued.
  ///
  /// In en, this message translates to:
  /// **'In line after step {number}'**
  String tutorialImageQueued(int number);

  /// No description provided for @tutorialImageTag.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String tutorialImageTag(String number);

  /// No description provided for @tutorialListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get tutorialListening;

  /// No description provided for @tutorialLoadingBody.
  ///
  /// In en, this message translates to:
  /// **'Kanz is writing steps for your skill and the tools you have. This takes about ten seconds.'**
  String get tutorialLoadingBody;

  /// No description provided for @tutorialLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Writing your tutorial'**
  String get tutorialLoadingTitle;

  /// No description provided for @tutorialMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark step done'**
  String get tutorialMarkDone;

  /// No description provided for @tutorialMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get tutorialMaterialsTitle;

  /// No description provided for @tutorialMissingAction.
  ///
  /// In en, this message translates to:
  /// **'Back to the ideas'**
  String get tutorialMissingAction;

  /// No description provided for @tutorialMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Its scan may have been deleted. Go back and pick another idea.'**
  String get tutorialMissingBody;

  /// No description provided for @tutorialMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'This idea isn\'t available'**
  String get tutorialMissingTitle;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get tutorialNext;

  /// No description provided for @tutorialNoHandsFree.
  ///
  /// In en, this message translates to:
  /// **'Hands-free isn\'t available on this phone. The buttons still work.'**
  String get tutorialNoHandsFree;

  /// No description provided for @tutorialNoSpeech.
  ///
  /// In en, this message translates to:
  /// **'This phone has no voice to read steps aloud. Voice commands still work.'**
  String get tutorialNoSpeech;

  /// No description provided for @tutorialNoVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice commands aren\'t available on this phone. Steps are read aloud; use the buttons to move.'**
  String get tutorialNoVoice;

  /// Thin banner under the app bar while a stored tutorial is open offline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. This tutorial is saved; new pictures and adapting need a connection.'**
  String get tutorialOfflineBanner;

  /// No description provided for @tutorialOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'This tutorial isn\'t saved on your phone yet. Connect to the internet and try again.'**
  String get tutorialOfflineBody;

  /// No description provided for @tutorialOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get tutorialOfflineTitle;

  /// No description provided for @tutorialOverview.
  ///
  /// In en, this message translates to:
  /// **'Back to the overview'**
  String get tutorialOverview;

  /// No description provided for @tutorialPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get tutorialPrevious;

  /// No description provided for @tutorialRedraw.
  ///
  /// In en, this message translates to:
  /// **'Redraw picture'**
  String get tutorialRedraw;

  /// No description provided for @tutorialSafetyNotes.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get tutorialSafetyNotes;

  /// No description provided for @tutorialSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get tutorialSafetyTitle;

  /// No description provided for @tutorialSourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'Based on'**
  String get tutorialSourcesLabel;

  /// No description provided for @tutorialSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Reading step {number} aloud'**
  String tutorialSpeaking(int number);

  /// No description provided for @tutorialSpecSkill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get tutorialSpecSkill;

  /// No description provided for @tutorialSpecSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get tutorialSpecSteps;

  /// No description provided for @tutorialSpecTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get tutorialSpecTime;

  /// No description provided for @tutorialSpecTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tutorialSpecTools;

  /// No description provided for @tutorialStart.
  ///
  /// In en, this message translates to:
  /// **'Start step 1'**
  String get tutorialStart;

  /// No description provided for @tutorialStepDone.
  ///
  /// In en, this message translates to:
  /// **'Step done'**
  String get tutorialStepDone;

  /// No description provided for @tutorialStepDoneHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to mark it not done'**
  String get tutorialStepDoneHint;

  /// No description provided for @tutorialStepDoneTag.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tutorialStepDoneTag;

  /// No description provided for @tutorialStepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String tutorialStepsCount(int count);

  /// No description provided for @tutorialStepsDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} steps done'**
  String tutorialStepsDone(int done, int total);

  /// No description provided for @tutorialStepsOpen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step isn\'t marked done. You can still finish.} other{{count} steps aren\'t marked done. You can still finish.}}'**
  String tutorialStepsOpen(int count);

  /// No description provided for @tutorialTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tutorialTip;

  /// No description provided for @tutorialToFinish.
  ///
  /// In en, this message translates to:
  /// **'Go to finishing'**
  String get tutorialToFinish;

  /// No description provided for @tutorialToGather.
  ///
  /// In en, this message translates to:
  /// **'To gather'**
  String get tutorialToGather;

  /// No description provided for @tutorialToolHave.
  ///
  /// In en, this message translates to:
  /// **'You have it'**
  String get tutorialToolHave;

  /// No description provided for @tutorialToolInstead.
  ///
  /// In en, this message translates to:
  /// **'Use instead'**
  String get tutorialToolInstead;

  /// No description provided for @tutorialToolMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get tutorialToolMissing;

  /// No description provided for @tutorialToolsReady.
  ///
  /// In en, this message translates to:
  /// **'{have} of {total} ready'**
  String tutorialToolsReady(int have, int total);

  /// No description provided for @tutorialToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tutorialToolsTitle;

  /// Tag on the adapted note right after the tutorial was rewritten.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get tutorialUpdated;

  /// No description provided for @tutorialVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Say “next”, “back” or “repeat”'**
  String get tutorialVoiceHint;
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
